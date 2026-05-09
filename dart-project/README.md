# Dart Project Asset Auto-Registration

This project is designed to automate the registration of asset folders in a Dart application. It helps prevent "AssetNotFound" errors by ensuring that the `pubspec.yaml` file is always up-to-date with the content folders present in the `assets/content/` directory.

## Project Structure

```
dart-project
├── assets
│   └── content
├── lib
│   └── main.dart
├── pubspec.yaml
├── tool
│   └── update_assets.dart
└── README.md
```

### Directory Descriptions

- **assets/content**: This directory is intended to hold content folders that may contain `.json` or `.md` files. The script will scan this directory recursively to identify all relevant subfolders.

- **lib/main.dart**: This file serves as the main entry point for the Dart application.

- **pubspec.yaml**: This file is the configuration file for the Dart project. It lists dependencies, assets, and other project settings.

- **tool/update_assets.dart**: This file contains the Dart script that scans the `assets/content/` directory recursively, identifies subfolders containing `.json` or `.md` files, reads the `pubspec.yaml`, locates the `flutter: -> assets:` section, and updates it with the newly discovered paths while preserving other asset paths.

## Usage

To update the asset paths in `pubspec.yaml`, run the following command:

```
dart run tool/update_assets.dart
```

After running the script, you should see a message indicating that the assets have been updated. Remember to run `flutter pub get` to apply the changes.

## Contributing

Feel free to contribute to this project by submitting issues or pull requests. Your feedback and suggestions are welcome!