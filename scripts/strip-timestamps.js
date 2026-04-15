import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
import { join, extname } from 'path';

const TARGET_DIRS = [
  '.cursor/rules',
  '.claude/skills',
  '.windsurf/rules',
  '.opencode/rules',
  '.continue/rules'
];

const TARGET_FILES = [
  'CLAUDE.md',
  'GEMINI.md',
  'AGENTS.md',
  '.github/copilot-instructions.md'
];

const EXTENSIONS = ['.md', '.mdc'];

function findFiles(dir) {
  const results = [];
  try {
    const entries = readdirSync(dir);
    for (const entry of entries) {
      const fullPath = join(dir, entry);
      const stat = statSync(fullPath);
      if (stat.isDirectory()) {
        results.push(...findFiles(fullPath));
      } else if (EXTENSIONS.includes(extname(entry))) {
        results.push(fullPath);
      }
    }
  } catch (e) {
    if (e.code === 'ENOENT') {
      // Directory doesn't exist—this is expected and not an error
      console.warn(`⚠️  Directory not found (skipping): ${dir}`);
    } else {
      // Unexpected error—rethrow
      throw e;
    }
  }
  return results;
}

function stripGeneratedLine(content) {
  return content.replace(/^Generated:.*\n/gm, '');
}

/**
 * Sorts rule sections alphabetically by heading.
 * Rule sections start with "### " and end before the next "### " or "## Context".
 * @param {string} content - The file content to process
 * @returns {string} - Content with rule sections sorted
 */
function sortRuleSections(content) {
  // Find the start of the first rule section (first "### " that's not in frontmatter)
  const lines = content.split('\n');
  let inFrontmatter = false;
  let frontmatterEndIndex = -1;
  
  // Detect frontmatter (YAML between ---)
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].trim() === '---') {
      if (!inFrontmatter) {
        inFrontmatter = true;
      } else {
        frontmatterEndIndex = i;
        inFrontmatter = false;
        break;
      }
    }
  }

  // Find all rule sections (### headings that come after frontmatter)
  const ruleSections = [];
  let currentSection = null;
  let contextStartIndex = -1;

  for (let i = Math.max(0, frontmatterEndIndex + 1); i < lines.length; i++) {
    const line = lines[i];

    // Check if we've hit the Context section (end of rule sections)
    if (line.trim().startsWith('## Context')) {
      contextStartIndex = i;
      if (currentSection) {
        ruleSections.push(currentSection);
        currentSection = null;
      }
      break;
    }

    // Check if this is a rule section heading
    if (line.trim().startsWith('### ')) {
      if (currentSection) {
        ruleSections.push(currentSection);
      }
      currentSection = {
        heading: line.trim(),
        startIndex: i,
        lines: [line]
      };
    } else if (currentSection) {
      currentSection.lines.push(line);
    }
  }

  // If no rule sections found, return original content
  if (ruleSections.length === 0) {
    return content;
  }

  // Sort rule sections alphabetically by heading (ignoring "### " prefix)
  ruleSections.sort((a, b) => {
    const headingA = a.heading.replace(/^###\s+/, '').toLowerCase();
    const headingB = b.heading.replace(/^###\s+/, '').toLowerCase();
    return headingA.localeCompare(headingB);
  });

  // Reassemble the content
  const beforeRules = lines.slice(0, ruleSections[0].startIndex).join('\n');
  const sortedRules = ruleSections.map(section => section.lines.join('\n')).join('\n');
  const afterRules = contextStartIndex >= 0 
    ? '\n' + lines.slice(contextStartIndex).join('\n')
    : '';

  return beforeRules + '\n' + sortedRules + afterRules;
}

// Collect all target files
let files = [];
for (const dir of TARGET_DIRS) {
  files = files.concat(findFiles(dir));
}
files = files.concat(TARGET_FILES.filter(f => {
  try {
    statSync(f);
    return true;
  } catch (e) {
    if (e.code === 'ENOENT') {
      console.warn(`⚠️  File not found (skipping): ${f}`);
    } else {
      throw e;
    }
    return false;
  }
}));

// Files that require rule section sorting (in addition to timestamp stripping)
const SORTING_FILES = ['CLAUDE.md', 'GEMINI.md', '.github/copilot-instructions.md'];

// Process each file
for (const file of files) {
  try {
    const content = readFileSync(file, 'utf8');
    let processed = stripGeneratedLine(content);

    // Apply rule section sorting to specific files
    const fileName = file.split('/').pop();
    if (SORTING_FILES.includes(fileName)) {
      processed = sortRuleSections(processed);
    }

    if (content !== processed) {
      writeFileSync(file, processed);
      console.log(`✅ Processed ${file}`);
    }
  } catch (e) {
    console.error(`❌ Failed to process ${file}: ${e.message}`);
    process.exitCode = 1;
  }
}

console.log('✨ Timestamp stripping and rule section sorting complete.');