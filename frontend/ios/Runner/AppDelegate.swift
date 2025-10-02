// ios/Runner/AppDelegate.swift
import UIKit
import Flutter
import GoogleMaps   // <- Importa el SDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Registra tu API Key de Google Maps (solo para iOS)
    GMSServices.provideAPIKey("AIzaSyCx9cJk46fqb6Q4otdSA4MPRMlUudZfGFU")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

