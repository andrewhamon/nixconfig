name="$1"

ssh-keygen -t ed25519-sk -N "" -C "and.ham95@gmail.com" -O "application=ssh:$name" -O resident
age-plugin-yubikey --generate --name "$name" --touch-policy cached --pin-policy once
