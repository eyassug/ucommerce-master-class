using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce.Infrastructure.Configuration;

namespace MyUCommerceApp.Integration
{
	public class InMemoryCommerceConfigurationProvider : CommerceConfigurationProvider
	{
		private readonly string _conncetionString;

		public InMemoryCommerceConfigurationProvider(string conncetionString)
		{
			_conncetionString = conncetionString;
		}

		public override RuntimeConfigurationSection GetRuntimeConfiguration()
		{
			return new RuntimeConfigurationSection
			{
				EnableCache = true,
				CacheProvider = "NHibernate.Caches.SysCache.SysCacheProvider, NHibernate.Caches.SysCache",
				ConnectionString = _conncetionString
			};
		}
	}
}
