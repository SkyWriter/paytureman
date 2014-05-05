require 'spec_helper'

describe "Payment" do

  let(:order_id) { SecureRandom.uuid }
  let(:amount) { 123.45 }
  let(:ip) { '123.45.67.89' }
  let(:session_id) { SecureRandom.uuid }

  let(:payture_mock) {
    Api.any_instance
  }

  it "should charge successfully" do
    payture_mock.stub(:init).with(order_id, amount*100, ip, {}).and_return(session_id)
    payture_mock.stub(:charge).with(order_id).and_return(true)

    payment = PaymentNew.new(order_id, amount, ip)

    payment = payment.prepare

    expect(payment).to be_kind_of(PaymentPrepared)

    payment = payment.block
    expect(payment).to be_kind_of(PaymentBlocked)


    payment = payment.charge
    expect(payment).to be_kind_of(PaymentCharged)
  end

  it "should unblock successfully" do
    payture_mock.stub(:init).with(order_id, amount*100, ip, {}).and_return(session_id)
    payture_mock.stub(:unblock).with(order_id, amount*100).and_return(true)

    payment = PaymentNew.new(order_id, amount, ip)

    payment = payment.prepare
    expect(payment).to be_kind_of(PaymentPrepared)

    payment = payment.block
    expect(payment).to be_kind_of(PaymentBlocked)

    payment = payment.unblock
    expect(payment).to be_kind_of(PaymentCancelled)
  end

  it "should refund successfully" do
    payture_mock.stub(:init).with(order_id, amount*100, ip, {}).and_return(session_id)
    payture_mock.stub(:charge).with(order_id).and_return(true)
    payture_mock.stub(:refund).with(order_id, amount*100).and_return(true)

    payment = PaymentNew.new(order_id, amount, ip)

    payment = payment.prepare
    expect(payment).to be_kind_of(PaymentPrepared)

    payment = payment.block
    expect(payment).to be_kind_of(PaymentBlocked)

    payment = payment.charge
    expect(payment).to be_kind_of(PaymentCharged)

    payment = payment.refund
    expect(payment).to be_kind_of(PaymentRefunded)
  end

  let(:init_payment_url) { "https://sandbox.payture.com/apim/Init" }
  let(:empty_response) { double('Request', body: '<xml />') }
  let(:product) { 'Order payment' }
  let(:total) { 1231 }

  it "should use additional params on request" do
    expect(RestClient).to receive(:post).with(
      init_payment_url,
      {
          "Data" => "SessionType=Block;OrderId=#{order_id};Amount=#{(amount*100).to_i};IP=#{ip};Product=#{URI.escape(product)};Total=#{total}",
          "Key" => "MerchantRutravel"
      }
    ).and_return(empty_response)

    payment = PaymentNew.new(order_id, amount, ip)

    payment.prepare(PaymentDescription.new(product, total))
  end

  it "should not use description in request if they not defined" do
    expect(RestClient).to receive(:post).with(
        init_payment_url,
        {
            "Data" => "SessionType=Block;OrderId=#{order_id};Amount=#{(amount*100).to_i};IP=#{ip}",
            "Key" => "MerchantRutravel"
        }
    ).and_return(empty_response)

    payment = PaymentNew.new(order_id, amount, ip)

    payment.prepare(PaymentDescription.new(nil, nil, nil, nil))
  end

  let(:real_configuration) {
    double('configuration').tap do |config|
      allow(config).to receive(:api_for).with(:real).and_return(Api.new('secure', 'MERCHANT100100', 'password'))
    end
  }

  it "should send valid params" do
    expect(RestClient).to receive(:post).with(
      "https://secure.payture.com/apim/Charge",
      {
          "OrderId" => order_id,
          "Password" => "password",
          "Key" => "MERCHANT100100"
      }
    ).and_return(empty_response)

    payment = PaymentBlocked.new(order_id, amount, 'session', :real)
    payment.configuration = real_configuration

    payment.charge
  end

  describe 'using same gateway when status changing' do
    before do
      Configuration.setup :settings do |config|
        config.host = 'host'
        config.key = 'key'
        config.password = 'password'
      end
    end

    it 'when charged' do
      payture_mock.stub(:init).with(order_id, amount*100, ip, {}).and_return(session_id)
      payture_mock.stub(:charge).with(order_id).and_return(true)

      payment = PaymentNew.new(order_id, amount, ip, :settings)

      payment = payment.prepare
      expect(payment.gateway).to eq :settings

      payment = payment.block
      expect(payment.gateway).to eq :settings

      payment = payment.charge
      expect(payment.gateway).to eq :settings
    end

    it "when unblocked" do
      payture_mock.stub(:init).with(order_id, amount*100, ip, {}).and_return(session_id)
      payture_mock.stub(:unblock).with(order_id, amount*100).and_return(true)

      payment = PaymentNew.new(order_id, amount, ip, :settings)

      payment = payment.prepare
      expect(payment.gateway).to eq :settings

      payment = payment.block
      expect(payment.gateway).to eq :settings

      payment = payment.unblock
      expect(payment.gateway).to eq :settings
    end

    it "when refunded" do
      payture_mock.stub(:init).with(order_id, amount*100, ip, {}).and_return(session_id)
      payture_mock.stub(:charge).with(order_id).and_return(true)
      payture_mock.stub(:refund).with(order_id, amount*100).and_return(true)

      payment = PaymentNew.new(order_id, amount, ip, :settings)

      payment = payment.prepare
      expect(payment.gateway).to eq :settings

      payment = payment.block
      expect(payment.gateway).to eq :settings

      payment = payment.charge
      expect(payment.gateway).to eq :settings

      payment = payment.refund
      expect(payment.gateway).to eq :settings
    end
  end

end