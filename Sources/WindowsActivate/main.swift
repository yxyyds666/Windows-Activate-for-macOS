import WindowsActivateKit

MainActor.assumeIsolated {
    WindowsActivateBootstrap.run(arguments: Array(CommandLine.arguments.dropFirst()))
}
