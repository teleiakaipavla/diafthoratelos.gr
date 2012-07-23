if AppConfig.is_shapadocom
  PaymentsConfig = YAML.load_file("#{Rails.root}/config/payments.yml")[Rails.env]

  if ShapadoVersion.count == 0
    ShapadoVersion.reload!
  end
else
  PaymentsConfig = {}
end

