#pragma once

/* Handle to one or more
 */
typedef unsigned int gpio

/* Open a particular output pin - requires an IO Switch
 */
gpio gpio_open(int pin)

/* Open an entire controller channel by base address
 */
gpio gpio_from_address(unsigned int base_address, unsigned int channel);

/* Open an entire controller channel by device ID
 */
gpio gpio_from_id(unsigned int id, unsigned int channel);

/* Select a subrange of GPIO pins - used to select an individual
 * pin or range from a controller bank. Can be used recursively.
 */
gpio gpio_select(gpio parent, unsigned int hi_bit, unsigned int low_bit);

/* Write outputs to the pin or pins referenced by `device`.
 * Does not affect the tri-state value of the pins so
 * writing to an input pin will have no effect.
 */
void gpio_write(gpio device, unsigned int value);

/* Read the inputs to the pin or pins referenced by `device`
 * Does not affect the tri-state value of the pins so
 * reading from an output pin will return 0
 */
unsigned int gpio_read(gpio device);

/* Sets the direction for one or pins. If `device` refers to
 * multiple pins then they will all be set in the same direction.
 * To set different directions for different pins use
 * gpio_select to target individual pins
 */
void gpio_direction(gpio device, int direction);

/* Close a `gpio` handle. The handle should not be used after being
 * closed
 */
void gpio_close(gpio device);
