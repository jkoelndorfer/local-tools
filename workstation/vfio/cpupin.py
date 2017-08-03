#!/usr/bin/env python3

import argparse
import json
import socket
import subprocess
import sys
import time


class QemuMonitor:
    def __init__(self, monitor_path: str):
        self.monitor_path = monitor_path

    def __enter__(self):
        self._monitor_socket = socket.socket(family=socket.AF_UNIX, type=socket.SOCK_STREAM)
        self._monitor_socket.connect(self.monitor_path)
        self.execute("qmp_capabilities")
        self._parse_response()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self._monitor_socket.close()

    def cpu_pids(self):
        res = self.execute("query-cpus")
        return [c["thread_id"] for c in res["return"]]

    def iothread_pids(self):
        res = self.execute("query-iothreads")
        return [c["thread-id"] for c in res["return"]]

    def execute(self, command, **kwargs):
        cmd = {"execute": command}
        if kwargs:
            cmd["args"] = kwargs
        cmd_json = json.dumps(cmd)
        self._monitor_socket.sendall(cmd_json.encode("utf-8"))
        return self._parse_response()

    def resume_execution(self):
        self.execute("cont")

    def _parse_response(self):
        result_bytes = b""
        result = None
        while result is None:
            result_bytes += self._monitor_socket.recv(1024)
            try:
                result = json.loads(result_bytes)
            except json.JSONDecodeError:
                # We haven't received the full response yet
                time.sleep(0.01)
        return result


class CpuPinningApplication:
    def __init__(self):
        self.configure_argparse()

    def configure_argparse(self):
        a = argparse.ArgumentParser()
        a.add_argument(
            "-c", "--smp-cpus", help="Comma separated list of CPUs to use for pinning QEMU cpu threads."
        )
        a.add_argument(
            "-i", "--iothread-cpus", help="Comma separated list of CPUs to use for pinning QEMU iothreads."
        )
        a.add_argument(
            "qemu_monitor", help="Path to the QEMU monitor socket."
        )
        self.argparser = a

    def pin_pid(self, pid, cpuid):
        subprocess.run(["taskset", "--cpu-list", "--pid", str(cpuid), str(pid)])
        subprocess.run(["chrt", "-f", "-p", "99", str(pid)])

    def run(self, argv):
        args = self.argparser.parse_args(argv)
        with QemuMonitor(args.qemu_monitor) as q:
            if args.iothread_cpus is not None:
                iothread_cpus = [int(i) for i in args.iothread_cpus.split(",")]
                qemu_iothread_pids = q.iothread_pids()
                for p in qemu_iothread_pids:
                    cpuid = iothread_cpus.pop()
                    self.pin_pid(p, cpuid)
            if args.smp_cpus is not None:
                smp_cpus = [int(i) for i in args.smp_cpus.split(",")]
                qemu_cpu_pids = q.cpu_pids()
                for p in qemu_cpu_pids:
                    cpuid = smp_cpus.pop()
                    self.pin_pid(p, cpuid)
            q.resume_execution()


if __name__ == "__main__":
    CpuPinningApplication().run(sys.argv[1:])
