__kernel void find_maxima_extend_maxima (
    IMAGE_binary_TYPE  binary,
    IMAGE_input_TYPE input,
    IMAGE_values_in_TYPE  values_in,
    IMAGE_values_out_TYPE  values_out,
    IMAGE_flag_TYPE  flag,
    float noise_threshold
)
{
  const sampler_t sampler  = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_NONE | CLK_FILTER_NEAREST;

  const int x = get_global_id(0);
  const int y = get_global_id(1);
  const int z = get_global_id(2);

  float binary_value = READ_IMAGE(binary, sampler, POS_binary_INSTANCE(x, y, z, 0)).x;
  float value = READ_IMAGE(input, sampler, POS_input_INSTANCE(x, y, z, 0)).x;
  float input_value = value;
  if (binary_value != 0) { // only check marked pixels

    float other_value = READ_IMAGE(values_in, sampler, POS_values_in_INSTANCE(x, y, z, 0)).x;
    if (other_value > value) {
        value = other_value;
    }

    other_value = READ_IMAGE(values_in, sampler, POS_values_in_INSTANCE(x + 1, y, z, 0)).x;
    if (other_value > value && other_value <= value + noise_threshold) {
        value = other_value;
    }

    other_value = READ_IMAGE(values_in, sampler, POS_values_in_INSTANCE(x - 1, y, z, 0)).x;
    if (other_value > value && other_value <= value + noise_threshold) {
        value = other_value;
    }

    other_value = READ_IMAGE(values_in, sampler, POS_values_in_INSTANCE(x, y + 1, z, 0)).x;
    if (other_value > value && other_value <= value + noise_threshold) {
        value = other_value;
    }

    other_value = READ_IMAGE(values_in, sampler, POS_values_in_INSTANCE(x, y - 1, z, 0)).x;
    if (other_value > value && other_value <= value + noise_threshold) {
        value = other_value;
    }

    if (get_global_size(2) > 1) {
        other_value = READ_IMAGE(values_in, sampler, POS_values_in_INSTANCE(x, y, z + 1, 0)).x;
        if (other_value > value && other_value <= value + noise_threshold) {
            value = other_value;
        }

        other_value = READ_IMAGE(values_in, sampler, POS_values_in_INSTANCE(x, y, z - 1, 0)).x;
        if (other_value > value && other_value <= value + noise_threshold) {
            value = other_value;
        }
    }







  } else {
    value = 0;
  }
  WRITE_IMAGE(values_out, POS_values_out_INSTANCE(x, y, z, 0), CONVERT_values_out_PIXEL_TYPE(value));

  if (input_value != value) {
    WRITE_IMAGE(flag, POS_flag_INSTANCE(0, 0, 0, 0), 1);
  }
}
