Sport Data Requirements
----------------------------
- Each sport has many leagues
- Each league has many seasons one of which is active
- Each league has many matches through seasons
- Each season has many matches and teams
- Each match has two teams
- Each team has a set of current players; players join and leave teams at any time, some players play in pitch some sit on the bench and some are reserve players
- On each particular match, a team has certain players on pitch, bench and reserve
- What is the latest linup for each team? (based on current members and last lineup)
- Each player has played and can actively play for many teams


Payment System Requirements
----------------------------
- Each user has a wallet
- Each match has a wallet
- App has a master wallet
- Wallets have addresses which can receive bitcoin from outside
- bitcoin received from outside increases unconfirmed balance of the wallet until at least one confirmation is received and balance becomes confirmed
- Bitcoin can be transfered between wallets
- unconfirmed balance can be used to pay for tickets
- If confirmation for unconfirmed payment is not received on time, payment needs to be rolled back
- Bitcoin can be transfered from a wallet to an external address
