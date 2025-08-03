const { execSync } = require('child_process');

try {
  execSync('bash build.sh', { stdio: 'inherit' });
} catch (error) {
  process.exit(1);
}