# encoding: UTF-8
require "spec_helper"

describe InboundMailProcessor do
  subject { InboundMailProcessor }

  it "should be on the inbound mail queue" do
    subject.queue.should == :inbound_mail
  end

  it "should respond to perform" do
    subject.should respond_to(:perform)
  end

  context "thread reply mail" do
    let(:thread) { FactoryGirl.create(:message_thread) }
    let(:email_recipient) { "thread-#{thread.public_token}@cyclescape.org" }
    let(:inbound_mail) { FactoryGirl.create(:inbound_mail, to: email_recipient) }

    context "plain text email" do
      before do
        subject.perform(inbound_mail.id)
      end

      it "should create a new message on the thread" do
        thread.should have(1).message
      end

      it "should have the same text as the email" do
        # There are weird newline issues here, each \r is duplicated in the model's response
        thread.messages.first.body.should == "Hi,\n\nCupcake ipsum dolor sit amet tart gummies. Sweet roll jelly pudding\nmacaroon ice cream. Halvah apple pie sweet. Halvah bear claw pudding.\nBonbon cake powder pastry. Jelly-o candy canes icing jelly macaroon.\nCandy topping chupa chups. Dessert biscuit biscuit gingerbread macaroon\nchupa chups wafer. Oat cake apple pie icing. Candy canes icing dessert.\n\nChocolate cake toffee dessert biscuit tootsie roll powder chocolate\njelly beans marzipan. Pastry tiramisu ice cream jujubes gummi bears.\nCaramels muffin cupcake candy. Caramels pie sweet roll. Jelly beans\ncupcake brownie. Chupa chups tootsie roll bonbon sesame snaps chocolate\ncake bear claw chocolate cake applicake cake. Jelly powder biscuit.\nChupa chups ice cream candy canes icing muffin jelly beans marshmallow.\nIce cream bonbon lemon drops lollipop. Croissant drage applicake\ntopping liquorice.\n\nAndrew\n"
      end

      it "should have be created by a new user with the email address" do
        thread.messages.first.created_by.email.should == inbound_mail.message.from.first
      end

      it "should subscribe the user to the thread" do
        thread.messages.first.created_by.subscribed_to_thread?(thread).should be_true
      end
    end

    context "multipart text-only email" do
      let(:inbound_mail) { FactoryGirl.create(:inbound_mail, :multipart_text_only, to: email_recipient) }

      before do
        subject.perform(inbound_mail.id)
      end

      it "should create a new message on the thread" do
        thread.should have(1).message
      end

      it "should have the same text as the email text part" do
        message_body = thread.messages.first.body
        message_body.should == "\n\nOn Tue, 20 Dec 2011, Cyclescape wrote:\n\n> Robin Bird added a message to the thread.\n>\n> I believe the idea is that 20m will be used to work out what to do and\n> how much that would cost. I therefore think that we do need to push for\n> cycle infrastructure along the A14 as a way of allowing them to justify\n> not widening the road quiet so much.\nI think the £20m is actually to implement things though, not a feasibility\nstudy. The current consultation seems to be about asking people what the\n£20m should be spent on:\n\nhttp://www.dft.gov.uk/consultations/dft-20111212\n\n\"schemes delivered over the next two years\""
      end
    end

    context "multipart email containing iso-8859-1 quoted-printable text" do
      let(:inbound_mail) { FactoryGirl.create(:inbound_mail, :multipart_iso_8859_1, to: email_recipient) }

      before do
        subject.perform(inbound_mail.id)
      end

      it "should create a new message on the thread" do
        thread.should have(1).message
      end

      it "should have the same text as the email text part" do
        message_body = thread.messages.first.body
        message_body.should == "\n\nOn Tue, 20 Dec 2011, Cyclescape wrote:\n\n> Robin Bird added a message to the thread.\n>\n> I believe the idea is that 20m will be used to work out what to do and\n> how much that would cost. I therefore think that we do need to push for\n> cycle infrastructure along the A14 as a way of allowing them to justify\n> not widening the road quiet so much.\nI think the £20m is actually to implement things though, not a feasibility\nstudy. The current consultation seems to be about asking people what the\n£20m should be spent on:\n\nhttp://www.dft.gov.uk/consultations/dft-20111212\n\n\"schemes delivered over the next two years\""
      end
    end

    context "notifications" do
      it "should be sent out" do
        ThreadNotifier.should_receive(:notify_subscribers) do |thread, type, message|
          thread.should be_a(MessageThread)
          type.should == :new_message
          message.should be_a(Message)
        end
        subject.perform(inbound_mail.id)
      end
    end
  end
end
