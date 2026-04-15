import { watch } from 'fs';
import { execSync } from 'child_process';
import path from 'path';

const RULES_DIR = path.join(process.cwd(), '.ai-rulez', 'rules');

console.log(`👀 Watching for changes in ${RULES_DIR}...`);

watch(RULES_DIR, { recursive: true }, (eventType, filename) => {
    if (filename?.endsWith('.md')) {
        console.log(`🔄 Rule changed: ${filename}`);
        try {
            execSync('pnpm rules:generate', { stdio: 'inherit' });
            console.log('✅ AI configs regenerated');
        } catch (err) {
            console.error('❌ Failed to regenerate AI configs:', err);
        }
    }
});