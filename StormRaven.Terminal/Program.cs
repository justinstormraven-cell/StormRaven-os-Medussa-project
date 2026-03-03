using System;
using System.IO;
using System.IO.Pipes;
using System.Text.Json;
using System.Threading.Tasks;

namespace StormRaven.Terminal
{
    class Program
    {
        static async Task Main()
        {
            Console.Clear();
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("=================================================");
            Console.WriteLine("       STORMRAVEN SHELL NEURAL LINK ACTIVE       ");
            Console.WriteLine("=================================================");
            Console.ResetColor();

            _ = Task.Run(async () => {
                while(true) {
                    try {
                        using var rx = new NamedPipeClientStream(".", "StormRaven_Telemetry", PipeDirection.In, PipeOptions.Asynchronous);
                        await rx.ConnectAsync();
                        using var reader = new StreamReader(rx);
                        while(!reader.EndOfStream) {
                            var line = await reader.ReadLineAsync();
                            Console.ForegroundColor = ConsoleColor.DarkGray;
                            Console.WriteLine($"\n[TELEMETRY] {line}");
                            Console.ResetColor();
                            Console.Write("StormRaven> "); 
                        }
                    } catch { await Task.Delay(1000); }
                }
            });

            await Task.Delay(1000); 
            
            while(true) {
                Console.Write("\nStormRaven> ");
                var input = Console.ReadLine();
                if (string.IsNullOrWhiteSpace(input)) continue;

                try {
                    using var tx = new NamedPipeClientStream(".", "StormRaven_Command", PipeDirection.Out, PipeOptions.Asynchronous);
                    await tx.ConnectAsync(2000);
                    using var writer = new StreamWriter(tx) { AutoFlush = true };
                    
                    var payload = new {
                        source = "Shell",
                        target = "odin",
                        intent_json = $"{{\"command\": \"{input}\"}}",
                        priority = 10
                    };
                    
                    await writer.WriteLineAsync(JsonSerializer.Serialize(payload));
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine("[√] Payload Injected into Ring-0 Grid.");
                    Console.ResetColor();
                } catch (Exception ex) {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine($"[!] Injection Failed: Hypervisor offline. ({ex.Message})");
                    Console.ResetColor();
                }
            }
        }
    }
}
