name="$1"

echo "Please set a PIN for fido"
ykman fido access change-pin
echo "Disabling OTP"
ykman config usb --disable otp
ssh-keygen -t ed25519-sk -N "" -C "and.ham95@gmail.com" -O "application=ssh:$name" -O resident
age-plugin-yubikey --generate --name "$name" --touch-policy cached --pin-policy once
