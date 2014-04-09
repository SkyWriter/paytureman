require 'spec_helper'

describe "Payment" do

  let(:order_id) { SecureRandom.uuid }
  let(:amount) { 123.45 }
  let(:ip) { '123.45.67.89' }
  let(:session_id) { SecureRandom.uuid }
  let(:payture_mock) {
    double("Payture").tap do |mock|
      expect(mock).to receive(:init).with(order_id, amount*100, ip).and_return(session_id)
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

end