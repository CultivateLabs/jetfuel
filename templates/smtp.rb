SMTP_SETTINGS = {
  address: ENV.fetch('SMTP_ADDRESS', 'smpt.sendgrid.net'), # example: 'smtp.sendgrid.net'
  authentication: :plain,
  domain: ENV.fetch('SMTP_DOMAIN', 'appname.com'), # example: 'this-app.com'
  enable_starttls_auto: true,
  password: ENV.fetch('SMTP_PASSWORD', 'defaultpassword'),
  port: '587',
  user_name: ENV.fetch('SMTP_USERNAME', 'defaultusername')
}
