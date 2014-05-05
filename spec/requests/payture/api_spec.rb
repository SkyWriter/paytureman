require 'spec_helper'

describe Api do

  let(:empty_response) { double('Request', body: '<xml />') }
  let(:host) { 'secure' }
  let(:key) { 'merchant' }
  let(:password) { 'password' }

  describe 'send request with defined host and key' do
    subject { Api.new(host, key, password) }

    it 'should send request with settings' do
      expect(RestClient).to receive(:post).with(
          "https://#{host}.payture.com/apim/Charge",
          {
              "OrderId" => 1,
              "Password" => password,
              "Key" => key
          }
      ).and_return(empty_response)

      subject.charge(1)
    end
  end


end