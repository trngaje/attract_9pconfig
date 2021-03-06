/* PRESETS */
Particles <- {
    "arc1": {
        resources = [ ParticleAnimation.BASE_PATH + "images/ball.png" ],
        ppm = 1,
        x = -50,
        y = 800,
        speed = [ 1450, 1450 ],
        angle = [ 290, 290 ],
        gravity = 40,
        lifespan = 7000
    },
    "bounce1": {
        resources = [ ParticleAnimation.BASE_PATH + "images/ball.png" ],
        ppm = 1,
        x = -80,
        y = 225,
        speed = [ 800, 800 ],
        angle = [ 20, 20 ],
        gravity = 40,
        accel = 3.5,
        bound = [ 0, 0, 3000, 650 ],
        rotate = [ 3, 3 ],
        scale = [ 0.5, 3 ],
        lifespan = 5000
    },
    "bubbles1": {
        resources = [ ParticleAnimation.BASE_PATH + "images/bubbles1.png" ],
        ppm = 200,
        x = 0,
        y = fe.layout.height,
        width = fe.layout.width,
        speed = [ 100, 250 ],
        angle = [ 360, 180 ],
        startScale = [ 0.5, 1.5 ],
        gravity = -2,
        fade=10000,
        lifespan = 10000
    },
    "cloudstoon": {
        resources = [ ParticleAnimation.BASE_PATH + "images/clouds-toon-1.png", ParticleAnimation.BASE_PATH + "images/clouds-toon-2.png", ParticleAnimation.BASE_PATH + "images/clouds-toon-3.png" ],
        ppm = 40,
        x = -325,
        y = -200,
        height = fe.layout.height,
        speed = [ 150, 300 ],
        lifespan = 15000
    },
    "cloudstoon2": {
        resources = [ ParticleAnimation.BASE_PATH + "images/clouds-toon2-1.png", ParticleAnimation.BASE_PATH + "images/clouds-toon2-2.png", ParticleAnimation.BASE_PATH + "images/clouds-toon2-3.png", ParticleAnimation.BASE_PATH + "images/clouds-toon2-4.png", ParticleAnimation.BASE_PATH + "images/clouds-toon2-5.png" ],
        ppm = 40,
        x = -175,
        y = -200,
        height = fe.layout.height,
        speed = [ 150, 300 ],
        lifespan = 15000
    },
    "default": {
        resources = [ ParticleAnimation.BASE_PATH + "images/default.png" ],
        ppm = 50,
        lifespan = 5000
    },
    "snow": {
        resources = [ ParticleAnimation.BASE_PATH + "images/snow.png" ],
        ppm = 500,
        x = 0,
        y = 0,
        width = fe.layout.width,
        speed = [ 100, 250 ],
        angle = [ 0, 180 ],
        startScale = [ 1, 2 ],
        gravity = 1,
        fade = 10000,
        lifespan = 10000
    },
    "sparkle": {
        resources = [ ParticleAnimation.BASE_PATH + "images/sparkle.png" ],
        ppm = 1000,
        x = 0,
        y = 0,
        width = fe.layout.width,
        height = fe.layout.height,
        speed = [ 0, 0 ],
        startScale = [ 1, 1.5 ],
        fade = 500,
        rotate = [ 1, 10 ],
        lifespan = 500
    },
    "invaders": {
        resources = [ ParticleAnimation.BASE_PATH + "images/invader.png", ParticleAnimation.BASE_PATH + "images/invader2.png", ParticleAnimation.BASE_PATH + "images/invader3.png" ],
        ppm = 100,
        x = 0,
        y = 0,
        width = fe.layout.width,
        height = fe.layout.height,
        speed = [ 0, 0 ],
        scale = [ 1, 1.5 ],
        rotate = [ -3, 3 ],
        fade = 1500,
        lifespan = 1500
    },
    "test": {
        resources = [ ParticleAnimation.BASE_PATH + "images/default.png" ],
        ppm = 60,
        x = fe.layout.width / 2,
        y = fe.layout.height - 100,
        width = 1,
        height = 1,
        angle = [ 90, 90 ],
        speed = [ 150, 150 ],
        accel = 0,
        rotate = [ 0, 0 ],
        rotateToAngle = false,
        scale = [ 1, 1 ],
        startScale = [ 1, 1 ],
        gravity = 0,
        lifespan = 6000,
        fade = 0,
        xOscillate = [ 10, 250 ]
    }
}
