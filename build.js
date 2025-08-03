const { execSync } = require('child_process');

try {
  execSync('bash build.sh', { stdio: 'inherit' });
} catch (error) {
  console.error('Build failed:', error);
  process.exit(1);
}
