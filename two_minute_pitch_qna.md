# Ghosts of the Sky — 2-Minute Pitch Q&A
**NASA Space Apps Challenge Hackathon Presentation**

---

### **Q1: What is this project?** *(0:00 – 0:30)*
> **"What is Ghosts of the Sky?"**

**Answer:**  
**Ghosts of the Sky** (*মহাকাশের ভুলে যাওয়া বন্ধুরা*) is an interactive space-archaeology app that turns abandoned NASA spacecraft—rovers, lunar landers, and deep space probes left behind across the solar system since the 1960s—into friendly, living characters that tell their own stories to school-age children.

---

### **Q2: What problem does it solve?** *(0:30 – 1:00)*
> **"What problem does this address?"**

**Answer:**  
Decades of human hardware sit silently across the Moon and Mars, yet school-age kids usually only hear about active missions. Historical mission data and scientific coordinates are locked away in dense, dry NASA archives. Kids lose interest before they can understand the monumental science these "space ghosts" made possible—like laser-ranging mirrors measuring continental drift, or rovers that proved ancient Mars had liquid water.

---

### **Q3: How does it solve it?** *(1:00 – 1:35)*
> **"How does the app actually work?"**

**Answer:**  
We solve this through four core pillars:
1. **Time Machine Storytelling:** Led by our companion robot Roby, students journey chronologically through space history—from 1960s lunar pioneers up to modern Mars rovers.
2. **Adaptive Age-Tiering:** Content automatically calibrates:
   - **Ages 4–9:** Relatable first-person personification and sensory wonder.
   - **Ages 10+:** Telemetry, scientific payloads, and geological discoveries.
3. **Interactive 3D Planetary Exploration:** Students scrub an interactive decade timeline and watch real 3D globes of the Moon and Mars fly directly to verified NASA landing coordinates.
4. **Bilingual Accessibility:** Complete native support for both English and Bengali (বাংলা) from day one.

---

### **Q4: What technologies power the project?** *(1:35 – 2:00)*
> **"What is the underlying tech stack?"**

**Answer:**  
We built a cross-platform hybrid architecture:
- **Flutter:** Powers smooth native 60fps UI, state management, age-tier switching, and interactive course timeline scrubbing.
- **Three.js (WebGL):** Handles real-time 3D planetary rendering, coordinate math (lat/lon to spherical 3D Cartesian vectors), lighting, and camera flight paths.
- **Bi-directional Bridge:** Seamless communication between Flutter and Three.js via `flutter_inappwebview`.
- **Verified NASA Data:** Bundled JSON knowledge base verified against NASA NSSDCA and LRO coordinates.

---

### ⏱️ Speaker Quick-Card (Cheat Sheet)

| Cue | Key Takeaway to Hit |
|---|---|
| **Identity** | Abandoned NASA hardware turned into storytelling "Space Ghosts" for kids. |
| **Problem** | Space history is trapped in dry archives; kids miss out on the science behind relics. |
| **Solution** | Time machine navigation + dual age tiers (4–9 vs 10+) + 3D globe explorer + Bengali & English. |
| **Tech** | Flutter UI + Three.js WebGL engine + Bi-directional bridge + NASA NSSDCA data. |

