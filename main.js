// ── Configurable form endpoint ──
// Replace with your Formspree URL or any form handler.
// Falls back to mailto if not configured.
const FORM_ENDPOINT = ''; // e.g. 'https://formspree.io/f/YOUR_ID'

const form = document.getElementById('waitlist-form');
if (form) {
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = form.querySelector('input[type="email"]').value.trim();
    if (!email) return;

    const btn = form.querySelector('button');
    const original = btn.textContent;

    if (FORM_ENDPOINT) {
      btn.textContent = 'Joining...';
      btn.disabled = true;
      try {
        const res = await fetch(FORM_ENDPOINT, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email }),
        });
        if (res.ok) {
          btn.textContent = 'You\'re in ✦';
          form.querySelector('input').value = '';
        } else {
          btn.textContent = 'Try again';
        }
      } catch {
        btn.textContent = 'Try again';
      }
      setTimeout(() => {
        btn.textContent = original;
        btn.disabled = false;
      }, 3000);
    } else {
      // Fallback: open mailto
      window.location.href =
        'mailto:mattathiasabraham@gmail.com?subject=LifeQuest%20Waitlist&body=' +
        encodeURIComponent('Waitlist signup: ' + email);
      btn.textContent = 'Email opened ✦';
      setTimeout(() => {
        btn.textContent = original;
      }, 3000);
    }
  });
}

// ── Reveal on scroll ──────────────────────────────────────────────────────
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.15 }
);

document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));
