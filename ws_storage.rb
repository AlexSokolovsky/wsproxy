# frozen_string_literal: true

module WSStorage
  STORAGE = {
    'users' => {},
    'appliances' => {},
    'b_pairs' => {},
    'logger' => {},
    'time_start' => {}
  }.freeze

  def self.clear(key, subkey)
    return unless STORAGE[key]
    STORAGE[key].delete(subkey)
  end

  def self.set(key, subkey)
    return unless STORAGE[key]
    STORAGE[key].merge!(subkey)
  end

  def self.get(key, subkey = nil)
    return unless (storage_key = STORAGE[key])
    return storage_key unless subkey
    storage_key[subkey]
  end
end
