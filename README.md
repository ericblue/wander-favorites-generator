
# Wander Favorites Generator

The Wander app for the Oculus Quest is an *amazing* virtual reality app that lets you (virtually) travel all over the world and immerse yourself with imagery from Google StreetView. The Wander App does allow you to save favorites/bookmarks of locations. And you have the ability to upload these favorite files to your headset with a USB cable and the Android File Transfer utility.

However, there is currently no way to easily create favorites outside of VR or to import places to visit in bulk given a simple set of geo coordinates. The goal with this app is to make it easy to plan your virtual trips in advance of putting the headset on, and make to make the process quick and easy.

Simply Get Started by entering your locations by name or latitude/longitude, and this tool will use Google StreetView APIs to lookup the corresponding panoid for each location, and generate a properly formatted Wander_Favorites.json file.

Note: A future update will allow importing of KML/KMZ/GPX (exported from a custom Google Map)

## Getting Started

A hosted version of this will be posted and shared shortly from my own personal website.
For those wishing to install and run this app on your own, setup should be fairly minimal.

* Requires Perl 5.x, Mojolicious (https://mojolicious.org/) and minimal dependencies (LWP, JSON, Log4Perl, etc)
* Requires you to create your own Google StreetView credentials/API keys and add to the app.conf file.
See: See: https://developers.google.com/maps/documentation/streetview/get-api-key

There's a command-line program (wander-favorites-cli.pl) and web server (wander-favorites-server.pl) 
running on port 3000 for dev and 30001 for production mode.

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

## Author

* This app was created by Eric Blue - https://eric-blue.com