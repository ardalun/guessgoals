require "rails_helper"

RSpec.describe NotifMailer, type: :mailer do
  describe "funds_received" do
    let(:mail) { NotifMailer.funds_received }

    it "renders the headers" do
      expect(mail.subject).to eq("Funds received")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "funds_confirmed" do
    let(:mail) { NotifMailer.funds_confirmed }

    it "renders the headers" do
      expect(mail.subject).to eq("Funds confirmed")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "funds_declined" do
    let(:mail) { NotifMailer.funds_declined }

    it "renders the headers" do
      expect(mail.subject).to eq("Funds declined")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "micro_funds_received" do
    let(:mail) { NotifMailer.micro_funds_received }

    it "renders the headers" do
      expect(mail.subject).to eq("Micro funds received")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "micro_funds_confirmed" do
    let(:mail) { NotifMailer.micro_funds_confirmed }

    it "renders the headers" do
      expect(mail.subject).to eq("Micro funds confirmed")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "micro_funds_declined" do
    let(:mail) { NotifMailer.micro_funds_declined }

    it "renders the headers" do
      expect(mail.subject).to eq("Micro funds declined")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "play_accepted" do
    let(:mail) { NotifMailer.play_accepted }

    it "renders the headers" do
      expect(mail.subject).to eq("Play accepted")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "play_declined" do
    let(:mail) { NotifMailer.play_declined }

    it "renders the headers" do
      expect(mail.subject).to eq("Play declined")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "match_started" do
    let(:mail) { NotifMailer.match_started }

    it "renders the headers" do
      expect(mail.subject).to eq("Match started")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "pool_won" do
    let(:mail) { NotifMailer.pool_won }

    it "renders the headers" do
      expect(mail.subject).to eq("Pool won")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "pool_lost" do
    let(:mail) { NotifMailer.pool_lost }

    it "renders the headers" do
      expect(mail.subject).to eq("Pool lost")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "payout_requested" do
    let(:mail) { NotifMailer.payout_requested }

    it "renders the headers" do
      expect(mail.subject).to eq("Payout requested")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "payout_sent" do
    let(:mail) { NotifMailer.payout_sent }

    it "renders the headers" do
      expect(mail.subject).to eq("Payout sent")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "payout_confirmed" do
    let(:mail) { NotifMailer.payout_confirmed }

    it "renders the headers" do
      expect(mail.subject).to eq("Payout confirmed")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
