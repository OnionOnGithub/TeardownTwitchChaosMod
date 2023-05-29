
import irc.bot
import requests
import keyboard
import random
import webbrowser


# Replace these with your own Twitch credentials
USERNAME = '' # your twitch user Name duh

TOKEN = '' # your twitch token
##To obtain your Twitch channel token, you can follow these steps:
##Go to the Twitch website (https://www.twitch.tv/) and log in to your Twitch account.
##Once logged in, click on your profile picture in the top-right corner of the screen.
##From the dropdown menu, select "Creator Dashboard."
##In the Creator Dashboard, click on the "Settings" tab on the left sidebar.
##Under the "Settings" tab, click on "Stream."
##Scroll down to the "Stream Key & Preferences" section.
##In the "Primary Stream Key" section, you will find your channel token. It is a unique alphanumeric string.
##Please note that your channel token is sensitive information that grants access to your Twitch channel. Keep it secure and avoid sharing it with others. If you suspect that your token has been compromised, 
# it is recommended to regenerate a new token for security purposes.

CHANNEL = '' # also twitch user Name if you dont have a different @ idk 
FILENAME = 'Z:\gettwitch\chat_log.txt'  # Name of the file to save chat log
PathToMod = "drive//user//documents//Teardown//mods//Chaosmod" # the path to the mod use your own path i cant now where you store the mod
# Define a function to handle incoming chat messages
def handle_message(connection, event):
    message = event.arguments[0]
    username = event.source.split('!')[0]
    print(f'{username}: {message}')
    
  


  
    # Save message to file
    if message == "1" or message == "2" or message == "3" or message == "4":
        with open(PathToMod + "\\twitchchat.xml", 'w') as xml:
        
        
            xml.write(f'<prefab version="1.3.0">\n  <group>\n       <body tags="twitch" dynamic="true" desc="{message}"/> \n	</group>\n</prefab>')


# Create a Twitch bot
class TwitchBot(irc.bot.SingleServerIRCBot):
    def __init__(self, username, token, channel):
        self.username = username
        self.token = token
        self.channel = '#' + channel
        self.twitch_server = 'irc.chat.twitch.tv'
        self.twitch_port = 6667
        irc.bot.SingleServerIRCBot.__init__(self, [(self.twitch_server, self.twitch_port, f'oauth:{token}')], username, username)

    def on_welcome(self, connection, event):
        connection.join(self.channel)

    def on_pubmsg(self, connection, event):
        handle_message(connection, event)

# Start the bot
bot = TwitchBot(USERNAME, TOKEN, CHANNEL)
bot.start()

