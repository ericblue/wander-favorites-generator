
# Wander Favorites Generator

The Wander app for the Oculus Quest is an *amazing* virtual reality app that lets you (virtually) travel all over the world and immerse yourself with imagery from Google StreetView. The Wander App does allow you to save favorites/bookmarks of locations. And you have the ability to upload these favorite files to your headset with a USB cable and the Android File Transfer utility.

However, there is currently no way to easily create favorites outside of VR or to import places to visit in bulk given a simple set of geo coordinates. The goal with this app is to make it easy to plan your virtual trips in advance of putting the headset on, and to make the process quick and easy.

Simply Get Started by entering your locations by name or latitude/longitude, and this tool will use Google StreetView APIs to lookup the corresponding panoid for each location, and generate a properly formatted Wander_Favorites.json file.

Note: A future update will allow importing of KML/KMZ/GPX (exported from a custom Google Map)

## Getting Started

A hosted version of this app is currently up for testing at http://app.eric-blue.com/wander/?src=github.
For those wishing to install and run this app on your own, setup should be fairly minimal.

* Requires Perl 5.x, Mojolicious (https://mojolicious.org/) and minimal dependencies (LWP, JSON, Log4Perl, etc)

  * On Ubuntu 18.x, the following commands may be needed to install dependencies:
      * cpanm install Mojolicious::Lite
      * cpanm install Log::Log4perl
      * cpanm install JSON
      * cpanm install LWP::UserAgent
      * apt-get install liblwp-protocol-https-perl
      

* Requires you to create your own Google StreetView credentials/API keys and add to the app.conf file.
See: https://developers.google.com/maps/documentation/streetview/get-api-key

### Running the Web Server

There's a command-line script and web server running Mojolicious (wander-favorites-server.pl).  Running this command
will present you with all the usual mojo comand-line options.  Additionally there are helper scripts - 
_run_dev.sh_ running on port 3000 for dev and _run.sh_ 30001 for production mode.

### Running from the CLI

There's a command-line script (wander-favorites-cli.pl) with some example code for processing locations directly in Perl.
Additionally there are some sample script using curl under curl_cli (curl_api_request.sh and curl_api_request_From_file.sh)
that make  it easy to type in some locations in terminal and get a favorites file generated using the REST API via Curl.

Ex:

`curl --silent --location --request POST 'http://localhost:3000/generate-favorites?folder=MyFolderName' \
--header 'Content-Type: text/plain' \
--data-raw \
'Los Angeles|LA
New York,The Big Apple' | \
jq -c '.favorites_json | fromjson' | jq .`

This will produce the following output, neatly encoded and formatted with jq (https://stedolan.github.io/jq/)

```
[
  {
    "folderContents": [
      {
        "panoid": "0EiP8k-A4dgq5WzxChtWFA",
        "title": "LA",
        "timeStamp": 164123687000000000,
        "isFolder": false
      },
      {
        "panoid": "CAoSLEFGMVFpcE13TlJpUEVXUUVYVjZHZE1UNVcwenBfTFhlNlEzcklVOXRfTTJ3",
        "title": "New York,The Big Apple",
        "timeStamp": 164123686999999000,
        "isFolder": false
      }
    ],
    "isFolder": true,
    "timeStamp": 164123687000000000,
    "title": "MyFolderName"
  }
]
```


## Wander Favorites File

The config file used by the Wander app is located on the headset and loaded at app launch.
While connected via USB to your computer and using the Android File Transfer  utility (https://www.android.com/filetransfer/)
you can navigate to Android -> data -> com.parkline.wander -> files and there will be a Wander_Favorites.json file.

Using this app you can copy the file to your clipboard or download to your computer.  This file
will need to be manually copied over to your headset, and the Wander app will need restarted.

Upon going to your Profile and Favorites you should see the new list of locations organized by your new folder name.


**Current Limitations**: There are no nested folders or multiple top-level folders.  Just a single
folder containing your new locations.  If you would like to add more folders or organize in a more
complex fashion, check out the Wander VR utilities project (https://sourceforge.net/projects/wander-vr-utilities/files/editor/).


## TODO

* Add support for KML/KMZ and possibly GPX support to import places easily from Google Maps or other geo apps
* Add spinner+progress indicator

## Author

* This app was created by Eric Blue - https://eric-blue.com
