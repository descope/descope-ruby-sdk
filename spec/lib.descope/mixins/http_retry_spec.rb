# frozen_string_literal: true

require 'spec_helper'

describe Descope::Mixins::HTTP do
  before(:all) do
    dummy_instance = DummyClass.new
    dummy_instance.extend(Descope::Mixins::HTTP)
    @instance = dummy_instance
  end

  describe '#request_with_retry transient error handling' do
    before do
      stub_const('Descope::Mixins::HTTP::TRANSIENT_RETRY_DELAYS', [0, 0, 0])
      allow(@instance).to receive(:sleep)
    end

    def mock_response(code, body = '')
      r = double('response')
      allow(r).to receive(:code).and_return(code)
      allow(r).to receive(:body).and_return(body)
      allow(r).to receive(:cookies).and_return({})
      allow(r).to receive(:headers).and_return({})
      allow(r).to receive(:respond_to?).with(:code).and_return(true)
      r
    end

    it 'retries on each retryable status code and succeeds on second attempt' do
      [503, 521, 522, 524, 530].each do |code|
        call_count = 0
        allow(@instance).to receive(:call) do
          call_count += 1
          call_count == 1 ? mock_response(code) : mock_response(200, '{"ok":true}')
        end

        result = @instance.request_with_retry(:get, '/test')
        expect(result).to eq({ 'ok' => true })
        expect(call_count).to eq(2), "expected 2 calls for #{code}, got #{call_count}"
      end
    end

    it 'retries up to 3 times and raises TransientError when all retries exhausted' do
      allow(@instance).to receive(:call).and_return(mock_response(503))

      expect { @instance.request_with_retry(:get, '/test') }.to raise_error(Descope::TransientError)
      expect(@instance).to have_received(:call).exactly(4).times
    end

    it 'does not retry on non-retryable status codes' do
      [400, 401, 403, 404, 500, 502].each do |code|
        call_count = 0
        allow(@instance).to receive(:call) do
          call_count += 1
          mock_response(code)
        end

        expect { @instance.request_with_retry(:get, '/test') }.to raise_error(Descope::HTTPError)
        expect(call_count).to eq(1), "should not retry on #{code}"
      end
    end

    it 'sleeps with the correct delay sequence' do
      stub_const('Descope::Mixins::HTTP::TRANSIENT_RETRY_DELAYS', [0.1, 5.0, 5.0])
      allow(@instance).to receive(:call).and_return(mock_response(503))

      expect { @instance.request_with_retry(:get, '/test') }.to raise_error(Descope::TransientError)
      expect(@instance).to have_received(:sleep).with(0.1).once
      expect(@instance).to have_received(:sleep).with(5.0).twice
    end

    it 'succeeds immediately without sleeping when first attempt succeeds' do
      allow(@instance).to receive(:call).and_return(mock_response(200, '{"ok":true}'))

      result = @instance.request_with_retry(:get, '/test')
      expect(result).to eq({ 'ok' => true })
      expect(@instance).not_to have_received(:sleep)
      expect(@instance).to have_received(:call).once
    end

    it 'succeeds on third retry (fourth total call)' do
      call_count = 0
      allow(@instance).to receive(:call) do
        call_count += 1
        call_count < 4 ? mock_response(503) : mock_response(200, '{"ok":true}')
      end

      result = @instance.request_with_retry(:get, '/test')
      expect(result).to eq({ 'ok' => true })
      expect(call_count).to eq(4)
    end
  end
end
