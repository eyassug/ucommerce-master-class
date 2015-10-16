using UCommerce.Infrastructure.Configuration;

namespace MyUCommerceApp.BusinessLogic.Integration
{
	public class InMemoryCommerceConfigurationProvider : CommerceConfigurationProvider
	{
		private readonly string _connectionString;

		public InMemoryCommerceConfigurationProvider(string connectionString)
		{
			_connectionString = connectionString;
		}

		public override RuntimeConfigurationSection GetRuntimeConfiguration()
		{
			return new RuntimeConfigurationSection
			{
				EnableCache = true,
				CacheProvider = "NHibernate.Caches.SysCache.SysCacheProvider, NHibernate.Caches.SysCache",
				ConnectionString = _connectionString
			};
		}
	}
}
