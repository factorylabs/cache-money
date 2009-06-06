require 'cache_money'

memcache_config = YAML.load_file(File.join(Rails.root,'config','memcached.yml'))

memcache_options = memcache_config['defaults'].merge(memcache_config[Rails.env])

unless memcache_options['disabled'] || Rails.env.test?
  $memcache = MemCache.new(memcache_options)
  $memcache.servers = memcache_options['servers']
else
  $memcache = Cash::Mock.new
end

ActionController::Base.session_options[:cache] = $memcache if memcache_options['sessions']
  
$local = Cash::Local.new($memcache)
$lock = Cash::Lock.new($memcache)
$cache = Cash::Transactional.new($local, $lock)

class ActiveRecord::Base
  is_cached :repository => $cache
end