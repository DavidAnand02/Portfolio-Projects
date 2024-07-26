let experience = 0;
let level = 1;
const maxLevel = 100;
const maxExperience = 10000;
const effects = {
    retention: 0,
    speed: 0
};

function addExperience(hours) {
    experience += hours;
    updateLevel();
    updateProgressBar('experience-bar', experience, maxExperience);
    document.getElementById('experience').innerText = experience;
}

function updateLevel() {
    let newLevel = Math.floor(Math.pow(experience / maxExperience, 1/2) * maxLevel);
    if (newLevel > maxLevel) newLevel = maxLevel;
    level = newLevel;
    document.getElementById('level').innerText = level;

    updateEffectProgress('retention-bar', level, effects.retention);
    updateEffectProgress('speed-bar', level, effects.speed);
}

function updateProgressBar(id, value, maxValue) {
    const progressBar = document.getElementById(id);
    const percentage = (value / maxValue) * 100;
    progressBar.style.width = `${percentage}%`;
}

function updateEffectProgress(id, level, effectLevel) {
    const effectStage = getEffectStage(level);
    const progressBar = document.getElementById(id);
    const stages = { beginner: 33, intermediate: 66, advanced: 100 };
    progressBar.style.width = `${stages[effectStage]}%`;
}

function getEffectStage(level) {
    if (level < 34) return 'beginner';
    if (level < 67) return 'intermediate';
    return 'advanced';
}

updateLevel();
