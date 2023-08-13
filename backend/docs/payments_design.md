
tx ro find mikoni
	agar find shod confirmationesho update mikoni
	nashod misazish

agar send gerefti
	ignore mikoni
	

agar receive gerefti
	agar addressesh tu db mojud bud, walletesho migiri emal mikoni
	agar addressesh tu db mojud nabud ignore mikoni


- someone sends from outside to charge their account (single or multiple vouts)
	yek tx miad ba yek ta chand ta receive
	address e har kodum o migiri wallet o peyda mikoni emal mikoni

- manually send from system wallet to charge an account
	yek tx miad ba ye seri joft send o receive be yek address
	receive ha address hashun mojud e ghaedatan
	send haro ignore mikkoni
	address e har receive o migiri wallet o peyda mikoni emal mikoni

- someone makes a payout to outside
	yek (ya yek seri) tx miad ke faghat send haye taki dare, be address aee ke external an
	tx hatman ghablan tu system sakhte shode peydash mikoni taghiratesho emal mikoni
	send haro ignore mikoni

- someone uses payout to charge their wallet (ui blocks this)
	yek (ya yek seri) tx miad ke joft send or receive dare, be address haye internal
	send haro ignore mikoni
	address e har receive o migiri wallet o peyda mikoni emal mikoni

- someone uses payout to send an internal address not existing in gg db
	yek (ya yek seri) tx miad ke joft send or receive dare, be address haye internal
	send haro ignore mikoni
	chun nemituni walleti baraye receive ha peyda koni unaro ham ignore mikoni

- manually send to outside
	tx miad ba yek ya chand ta send
	chun send e ignore mishe

- receive from outside to an address not existing in gg db
	chun nemituni walleti baraye receive ha peyda koni unaro ham ignore mikoni


