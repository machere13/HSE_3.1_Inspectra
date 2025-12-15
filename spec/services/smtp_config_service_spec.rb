require 'rails_helper'

RSpec.describe SmtpConfigService, type: :service do
  describe '.supported_domains' do
    it 'should return array of supported domains' do
      domains = SmtpConfigService.supported_domains
      expect(domains).to be_an(Array)
      expect(domains).to include('gmail.com', 'yandex.ru', 'mail.ru')
    end
  end

  describe '.get_smtp_config' do
    it 'should return config for gmail.com' do
      config = SmtpConfigService.get_smtp_config('test@gmail.com')
      expect(config[:address]).to eq('smtp.gmail.com')
      expect(config[:port]).to eq(587)
    end

    it 'should return config for yandex.ru' do
      config = SmtpConfigService.get_smtp_config('test@yandex.ru')
      expect(config[:address]).to eq('smtp.yandex.ru')
    end

    it 'should return config for mail.ru' do
      config = SmtpConfigService.get_smtp_config('test@mail.ru')
      expect(config[:address]).to eq('smtp.mail.ru')
    end

    it 'should return default config for unsupported domain' do
      config = SmtpConfigService.get_smtp_config('test@unknown.com')
      expect(config[:address]).to eq('smtp.gmail.com')
    end

    it 'should handle case insensitive email' do
      config1 = SmtpConfigService.get_smtp_config('test@GMAIL.COM')
      config2 = SmtpConfigService.get_smtp_config('test@gmail.com')
      expect(config1[:address]).to eq(config2[:address])
    end
  end
end

