# encoding: UTF-8
require 'spec_helper'

describe InboundMailProcessor do
  subject { InboundMailProcessor }

  it 'should be on the inbound mail queue' do
    expect(subject.queue).to eq(:mailers)
  end

  it 'should respond to perform' do
    expect(subject).to respond_to(:perform)
  end

  # This context block can be deleted when we stop accepting old thread reply ids
  context 'thread reply mail' do
    let!(:thread) { create(:message_thread) }
    let(:email_recipient) { "thread-#{thread.public_token}@cyclescape.org" }
    before do
      subject.perform(inbound_mail.id)
      thread.reload
    end

    context 'plain text email' do
      let(:inbound_mail) { create(:inbound_mail, to: email_recipient) }

      it 'should create a new message on the thread' do
        expect(thread.messages.size).to eq(1)
      end

      it 'should have the same text as the email' do
        # There are weird newline issues here, each \r is duplicated in the model's response
        expect(thread.messages.first.body).
          to eq("<p>Hi,</p>\n\n<p>Cupcake ipsum dolor sit amet tart gummies. Sweet roll jelly pudding\n<br>macaroon ice cream. Halvah apple pie sweet. Halvah bear claw pudding.\n<br>Bonbon cake powder pastry. Jelly-o candy canes icing jelly macaroon.\n<br>Candy topping chupa chups. Dessert biscuit biscuit gingerbread macaroon\n<br>chupa chups wafer. Oat cake apple pie icing. Candy canes icing dessert.</p>\n\n<p>Chocolate cake toffee dessert biscuit tootsie roll powder chocolate\n<br>jelly beans marzipan. Pastry tiramisu ice cream jujubes gummi bears.\n<br>Caramels muffin cupcake candy. Caramels pie sweet roll. Jelly beans\n<br>cupcake brownie. Chupa chups tootsie roll bonbon sesame snaps chocolate\n<br>cake bear claw chocolate cake applicake cake. Jelly powder biscuit.\n<br>Chupa chups ice cream candy canes icing muffin jelly beans marshmallow.\n<br>Ice cream bonbon lemon drops lollipop. Croissant drage applicake\n<br>topping liquorice.</p>\n\n<p>Andrew\n</p>")
      end

      it 'should have be created by a new user with the email address' do
        expect(thread.messages.first.created_by.email).to eq(inbound_mail.message.from.first)
      end

      it 'should subscribe the user to the thread' do
        expect(thread.messages.first.created_by.subscribed_to_thread?(thread)).to be_truthy
      end

      it 'should be sent out' do
        expect(ThreadNotifier).to receive(:notify_subscribers) do |thread, message|
          expect(thread).to be_a(MessageThread)
          expect(message).to be_a(Message)
        end
        subject.perform(inbound_mail.id)
      end
    end
  end

  context 'message reply mail' do
    let(:message) { create(:message) }
    let(:thread) { message.thread }
    let(:email_recipient) { "message-#{message.public_token}@cyclescape.org" }
    before do
      subject.perform(inbound_mail.id)
      thread.reload
    end

    context 'plain text email' do
      let(:inbound_mail) { create(:inbound_mail, to: email_recipient) }

      it 'should create a new message on the thread' do
        expect(thread.messages.size).to eq(2)
      end

      it 'should have the same text as the email' do
        # There are weird newline issues here, each \r is duplicated in the model's response
        expect(thread.messages.last.body).
          to eq("<p>Hi,</p>\n\n<p>Cupcake ipsum dolor sit amet tart gummies. Sweet roll jelly pudding\n<br>macaroon ice cream. Halvah apple pie sweet. Halvah bear claw pudding.\n<br>Bonbon cake powder pastry. Jelly-o candy canes icing jelly macaroon.\n<br>Candy topping chupa chups. Dessert biscuit biscuit gingerbread macaroon\n<br>chupa chups wafer. Oat cake apple pie icing. Candy canes icing dessert.</p>\n\n<p>Chocolate cake toffee dessert biscuit tootsie roll powder chocolate\n<br>jelly beans marzipan. Pastry tiramisu ice cream jujubes gummi bears.\n<br>Caramels muffin cupcake candy. Caramels pie sweet roll. Jelly beans\n<br>cupcake brownie. Chupa chups tootsie roll bonbon sesame snaps chocolate\n<br>cake bear claw chocolate cake applicake cake. Jelly powder biscuit.\n<br>Chupa chups ice cream candy canes icing muffin jelly beans marshmallow.\n<br>Ice cream bonbon lemon drops lollipop. Croissant drage applicake\n<br>topping liquorice.</p>\n\n<p>Andrew\n</p>")
      end

      it 'should have be created by a new user with the email address' do
        expect(thread.messages.last.created_by.email).to eq(inbound_mail.message.from.first)
      end

      it 'should subscribe the user to the thread' do
        expect(thread.messages.last.created_by.subscribed_to_thread?(thread)).to be_truthy
      end

      it 'should be sent out' do
        expect(ThreadNotifier).to receive(:notify_subscribers) do |thread, message|
          expect(thread).to be_a(MessageThread)
          expect(message).to be_a(Message)
        end
        subject.perform(inbound_mail.id)
      end
    end

    context 'multipart text-only email' do
      let(:inbound_mail) { create(:inbound_mail, :multipart_text_only, to: email_recipient) }

      it 'should create a new message on the thread' do
        expect(thread.messages.size).to eq(2)
      end

      it 'should have the same text as the email text part' do
        message_body = thread.messages.last.body
        expect(message_body).to eq("<p>\nOn Tue, 20 Dec 2011, Cyclescape wrote:</p>\n\n<p>&gt; Robin Bird added a message to the thread.\n<br>&gt;\n<br>&gt; I believe the idea is that 20m will be used to work out what to do and\n<br>&gt; how much that would cost. I therefore think that we do need to push for\n<br>&gt; cycle infrastructure along the A14 as a way of allowing them to justify\n<br>&gt; not widening the road quiet so much.</p>\n\n<p>I think the £20m is actually to implement things though, not a feasibility\n<br>study. The current consultation seems to be about asking people what the\n<br>£20m should be spent on:</p>\n\n<p><a href=\"http://www.dft.gov.uk/consultations/dft-20111212\">http://www.dft.gov.uk/consultations/dft-20111212</a></p>\n\n<p>\"schemes delivered over the next two years\"\n</p>")
      end
    end

    context 'multipart email containing iso-8859-1 quoted-printable text' do
      let(:inbound_mail) { create(:inbound_mail, :multipart_iso_8859_1, to: email_recipient) }

      it 'should create a new message on the thread' do
        expect(thread.messages.size).to eq(2)
      end

      it 'should have the same text as the email text part' do
        message_body = thread.messages.last.body
        expect(message_body).to eq("<p>\nOn Tue, 20 Dec 2011, Cyclescape wrote:</p>\n\n<p>&gt; Robin Bird added a message to the thread.\n<br>&gt;\n<br>&gt; I believe the idea is that 20m will be used to work out what to do and\n<br>&gt; how much that would cost. I therefore think that we do need to push for\n<br>&gt; cycle infrastructure along the A14 as a way of allowing them to justify\n<br>&gt; not widening the road quiet so much.</p>\n\n<p>I think the £20m is actually to implement things though, not a feasibility\n<br>study. The current consultation seems to be about asking people what the\n<br>£20m should be spent on:</p>\n\n<p><a href=\"http://www.dft.gov.uk/consultations/dft-20111212\">http://www.dft.gov.uk/consultations/dft-20111212</a></p>\n\n<p>\"schemes delivered over the next two years\"\n</p>")
      end
    end

    context 'multipart email with image attachment' do
      let(:inbound_mail) { create(:inbound_mail, :with_attached_image, to: email_recipient) }

      it 'should create two new messages on the thread' do
        expect(thread.messages.size).to eq(3)
      end

      it 'should have the first message as the plain text part' do
        message_body = thread.messages[1].body
        expect(message_body).to eq("<p>This email has an attached image.</p>\n\n<p>Andy</p>")
      end

      it 'should have the second image as a photo message' do
        new_message = thread.messages[2]
        expect(new_message.component).to be_a(PhotoMessage)
        expect(new_message.component.caption).to eq('abstract-100-100.jpg')
        expect(new_message.component.photo.format).to eq('jpeg')
        expect(new_message.component.photo.width).to eql(100)
      end

      it 'should send multiple notifications' do
        expect(ThreadNotifier).to receive(:notify_subscribers).with(be_a(MessageThread), be_a(Message)).twice

        subject.perform(inbound_mail.id)
      end
    end

    context 'multipart email with file attachment' do
      let(:inbound_mail) { create(:inbound_mail, :with_attached_file, to: email_recipient) }

      it 'should create two new messages on the thread' do
        expect(thread.messages.size).to eq(3)
      end

      it 'should have the first message as the plain text part' do
        message_body = thread.messages[1].body
        expect(message_body).to eq("<p>This email has an attached file.</p>\n\n<p>Andy</p>")
      end

      it 'should have the second message as an attachment message' do
        message = thread.messages[2]
        expect(message.component).to be_a(DocumentMessage)
        expect(message.component.title).to eq('use_cases.pdf')
        expect(message.component.file.size).to eql(77_825)
      end
    end

    context 'with an encoded subject' do
      let(:inbound_mail) { create(:inbound_mail, :encoded_subject, to: email_recipient) }

      it 'should work without throwing an encoding error' do
        expect(thread.messages.size).to eq(2)
      end
    end

    context 'with a reply below a quote' do
      let(:inbound_mail) { create(:inbound_mail, :reply_below_quote, to: email_recipient) }

      it "should preserve the blank line between quote and reply" do
        message_body = thread.messages.last.body
        expect(message_body).to eql("<p>On Tue, 20 Dec 2011, Cyclescape wrote:\n<br>&gt; Robin Bird added a message to the thread.\n<br>&gt;\n<br>&gt; I believe the idea is that 20m will be used to work out what to do</p>\n\n<p>I believe this is the case too</p>\n\n<p>Andy\n</p>")
      end
    end
  end
end
