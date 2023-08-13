from telethon import TelegramClient, events, sync
import sys

with TelegramClient('meysam_to_guessgoalsbot', sys.argv[1], sys.argv[2]) as client:
  client.send_file('guessgoalsbot', sys.argv[3], caption=sys.argv[4])