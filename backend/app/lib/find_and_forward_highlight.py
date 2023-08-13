from telethon import TelegramClient, events, sync
import sys

with TelegramClient('meysam_to_guessgoalsbot', sys.argv[1], sys.argv[2]) as client:
  found = client.get_messages('@sky_sports_video', search=sys.argv[3], limit=100)
  for message in reversed(found):
    if int(sys.argv[4]) <= message.date.timestamp() and message.date.timestamp() <= int(sys.argv[5]):
      print(message.id)
      client.forward_messages('@guessgoalsbot', message)
      break