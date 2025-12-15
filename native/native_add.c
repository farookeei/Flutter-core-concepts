#include <stdint.h>
#include <unistd.h> // For sleep()

// A simple function to add two numbers
// We use int32_t to ensure size consistency across platforms
int32_t native_add(int32_t x, int32_t y) {
    return x + y;
}

// A function that simulates heavy work to demonstrate blocking behavior
// It performs a loop and sleeps, which will freeze the UI if called from the main thread.
int32_t heavy_computation(int32_t iterations) {
    int32_t sum = 0;
    for (int32_t i = 0; i < iterations; i++) {
        sum += i;
        // checking equality to waste time unpredictably so compiler doesn't optimize it away perfectly
        if (i % 1000 == 0) {
            sum ^= i; 
        }
    }
    // Artificial delay to make it noticeable even with small iterations
    // sleep takes seconds. iterations implies CPU work, but let's just force a sleep
    // to guarantee the "Freeze" effect is felt.
    if (iterations > 0) {
        usleep(2000 * 1000); // Sleep for 2 seconds
    }
    return sum;
}
