require 'spec_helper'

describe "Payment" do

  let(:order_id) { SecureRandom.uuid }
  let(:amount) { 123.45 }
  let(:ip) { '123.45.67.89' }
  let(:session_id) { SecureRandom.uuid }

  let(:payture_mock) {
    double("Payture").tap do |mock|
      expect(mock).to receive(:init).with(order_id, amount*100, ip, {}).and_return(session_id)
    end
  }

  it "should charge successfully" do
    expect(payture_mock).to receive(:charge).with(order_id, session_id).and_return(true)

    payment = PaymentNew.new(order_id, amount, ip)
    payment.payture = payture_mock

    payment = payment.prepare

    expect(payment).to be_kind_of(PaymentPrepared)

    payment = payment.block
    expect(payment).to be_kind_of(PaymentBlocked)

    payment.payture = payture_mock
    payment = payment.charge
    expect(payment).to be_kind_of(PaymentCharged)
  end

  it "should unblock successfully" do
    expect(payture_mock).to receive(:unblock).with(order_id, amount*100).and_return(true)

    payment = PaymentNew.new(order_id, amount, ip)
    payment.payture = payture_mock

    payment = payment.prepare
    expect(payment).to be_kind_of(PaymentPrepared)

    payment = payment.block
    expect(payment).to be_kind_of(PaymentBlocked)

    payment.payture = payture_mock
    payment = payment.unblock
    expect(payment).to be_kind_of(PaymentCancelled)
  end

  it "should refund successfully" do
    expect(payture_mock).to receive(:charge).with(order_id, session_id).and_return(true)
    expect(payture_mock).to receive(:refund).with(order_id, amount*100).and_return(true)

    payment = PaymentNew.new(order_id, amount, ip)
    payment.payture = payture_mock

    payment = payment.prepare
    expect(payment).to be_kind_of(PaymentPrepared)

    payment = payment.block
    expect(payment).to be_kind_of(PaymentBlocked)

    payment.payture = payture_mock
    payment = payment.charge
    expect(payment).to be_kind_of(PaymentCharged)

    payment.payture = payture_mock
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

  it "should send valid params" do
    expect(RestClient).to receive(:post).with(
        "https://sandbox.payture.com/apim/Charge",
        {
            "OrderId" => order_id,
            "Password" => "123",
            "Key" => "MerchantRutravel"
        }
    ).and_return(empty_response)

    payment = PaymentBlocked.new(order_id, amount, ip, 'session')

    payment.charge
  end

end