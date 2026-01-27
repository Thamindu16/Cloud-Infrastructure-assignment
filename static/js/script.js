document.addEventListener('DOMContentLoaded', () => {
    const card = document.getElementById('mainCard');

    // Toggle flip on click
    card.addEventListener('click', () => {
        card.classList.toggle('is-flipped');
    });

    // Optional: Add some interactive sound effect or haptic feedback if needed
    // For now, just handling the flip state
});
