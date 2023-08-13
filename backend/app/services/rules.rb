class Rules
  MINIMUM_ACCEPTABLE_CREDIT = 0.001
  TICKET_FEE = 0.001
end

# Calculates what is the average profit if n players bet
# on avg 250 games per month
def simit(games, pool_size_range)
  profit = 0.0
  games.times do
    n = rand(pool_size_range)
    next if n < 2
    ticket_fee  = 100.0
    total       = n * ticket_fee
    prize       = n == 2 ? ticket_fee * 2 : n == 3 ? n * ticket_fee * 0.83333 : n * ticket_fee * 0.7
    bad         = total - prize - ticket_fee
    good        = total
    bad_chance  = 100.0 * (n - 1.0)/n
    good_chance = 100.0 * 1.0/n
  
    event = rand(101)
    if event < good_chance
      profit += good
    else
      profit += bad
    end
  end
  puts profit
end