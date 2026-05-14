# Adobe Font Downloader

This script automatically installs Adobe Fonts on your macOS system that you have previously downloaded through the official Adobe Fonts website.

## Description

This Bash script performs the following actions:

1. Locates hidden font files downloaded when you clicked "Add Family" on the Adobe Fonts website.
2. Analyzes the XML file containing information about these synchronized fonts.
3. Checks for fonts already installed on your system.
4. Copies and installs missing fonts into the user's font folder on macOS.

The script specifically processes the small hidden files that are downloaded to your machine when you add a font family via the Adobe Fonts web interface. It effectively installs these fonts completely on your macOS device, making them available to all your applications.

## Usage

1. Ensure you have previously added the desired fonts via the official Adobe Fonts website by clicking "Add Family".
2. Clone this repository to your local machine.
3. Make the script executable: `chmod +x AdobeDownloader.sh`
4. Run the script: `./AdobeDownloader.sh`

## Prerequisites

- macOS
- Write access to the `/Users/{username}/Library/Fonts/` folder
- Having previously "added" the desired fonts via the Adobe Fonts web interface

## Important Warning

**CAUTION: The use of this script is not in compliance with Adobe Fonts' terms of service.**

This script was created for educational and demonstration purposes only. Using this script to install Adobe Fonts in this manner may violate Adobe's terms of service and the copyrights of font creators.

The author of this script disclaims all responsibility related to its use. By using this script, you accept full responsibility for your actions and any consequences that may result.

It is strongly recommended to use only the official methods provided by Adobe to access and use Adobe Fonts.

## License

This project is under the MIT License. See the `LICENSE` file for more details.

## Contribution

Contributions to this project are not encouraged due to potential legal and ethical issues associated with its use.

## Disclaimer

This project is not affiliated, associated, authorized, endorsed by, or in any way officially connected with Adobe Inc., or any of its subsidiaries or affiliates. This is an independent project that interacts with files downloaded through Adobe's official services, but its use is not approved by Adobe.
