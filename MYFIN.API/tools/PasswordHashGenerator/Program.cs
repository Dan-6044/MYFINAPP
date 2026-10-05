using System;
using Microsoft.AspNetCore.Identity;

namespace PasswordHashGenerator;

internal class Program
{
    private static void Main(string[] args)
    {
        Console.Write("Enter password to hash: ");
        var password = Console.ReadLine();

        if (string.IsNullOrWhiteSpace(password))
        {
            Console.WriteLine("Password cannot be empty.");
            return;
        }

        var hasher = new PasswordHasher<object>();
        var hash = hasher.HashPassword(null, password);

        Console.WriteLine();
        Console.WriteLine("Password Hash:");
        Console.WriteLine(hash);
        Console.WriteLine();
        Console.WriteLine($"Length: {hash.Length} characters");
    }
}
