#!/bin/sh

# Replace placeholders in next.config.js with values from environment variables before the node server gets
# started because Next.js doesn't support environment variables in next.config.js.
echo "Replacing placeholders in server.js and .next/routes-manifest.json with environment variables..."

# Write to temporary files first to prevent the file from being
# truncated and deleted before the substitution takes place
envsubst < /app/server.js >/tmp/server.js
envsubst < /app/.next/routes-manifest.json >/tmp/routes-manifest.json
envsubst < /app/.next/required-server-files.json >/tmp/required-server-files.json

# Show the diff between the server.js files to see what envsubst replaced
echo "Replaced following placeholders in server.js:"
echo "(expect a long json string)"
diff /app/server.js /tmp/server.js

# JSON is all one inline string, so we need to pretty print it to make it easier to diff
jq '.' /app/.next/routes-manifest.json >/tmp/routes-manifest.pretty.json
jq '.' /tmp/routes-manifest.json >/tmp/routes-manifest.replaced.pretty.json

jq '.' /app/.next/required-server-files.json >/tmp/required-server-files.pretty.json
jq '.' /tmp/required-server-files.json >/tmp/required-server-files.replaced.pretty.json

# Show the diff between the prettified JSON files to see what envsubst replaced
echo "Replaced following placeholders in .next/routes-manifest.json:"
diff /tmp/routes-manifest.pretty.json /tmp/routes-manifest.replaced.pretty.json

echo "Replaced following placeholders in .next/required-server-files.json:"
diff /tmp/required-server-files.pretty.json /tmp/required-server-files.replaced.pretty.json

# Clean up temporary prettified JSON 
# Move the temporary files to the original location

echo "Moving temporary files to original location..."

mv /tmp/server.js /app/server.js -v
mv /tmp/routes-manifest.json /app/.next/routes-manifest.json -v 
mv /tmp/required-server-files.json /app/.next/required-server-files.json -v

# Start the Next.js server
exec node /app/server.js
