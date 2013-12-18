using System.Linq;
using NUnit.Framework;
using Rhino.Mocks;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Configuration;
using NHibernate.Linq;
using UCommerce.Security;

namespace MyUCommerceApp.Test
{

	[TestFixture]
	public class QueryTests
	{
		private const string CONNECTIONSTRING = @"server=localhost\sqlexpress;database=Master-Class;user id=Master-Class;password=123";

		[Test]
		public void Test()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var order = session.Query<PurchaseOrder>().First();
			}
		}

		[Test]
		public void LamdaQuery()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.Query<Product>()
					.Where(product => product.DisplayOnSite && product.AllowOrdering);
				var products = query.ToList();
			}
		}

		[Test]
		public void LinqQuery()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = from line in session.Query<OrderLine>()
					where line.Price > 10
					join product in session.Query<Product>()
						on new { line.Sku, line.VariantSku }
						equals new { product.Sku, product.VariantSku }
					select new { line, product };
				
				var orders = query.ToList();
			}
		}

		[Test]
		public void LinqPreFetchingQuery()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.Query<Product>()
					.Fetch(x => x.ProductProperties);
				var products = query.ToList();

				foreach (var product in products)
				{
					string name = product.Name;

					foreach (var property in product.ProductProperties)
					{
						string value = property.Value;
					}
				}
			}
		}

		[Test]
		public void HqlQuery()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session
						.CreateQuery(@"
							select p from Product p
							left join fetch p.Variants")
						.Future<Product>();
				var orders = query.ToList();
			}
		}

		private SessionProvider GetSessionProvider()
		{
			var commerceConfigProviderStub = MockRepository.GenerateStub<CommerceConfigurationProvider>();
			commerceConfigProviderStub
				.Stub(x => x.GetRuntimeConfiguration())
				.Return(new RuntimeConfigurationSection
				{
					EnableCache = true,
					CacheProvider = "NHibernate.Caches.SysCache2.SysCacheProvider, NHibernate.Caches.SysCache2",
					ConnectionString = CONNECTIONSTRING
				});

			var userServiceStub = MockRepository.GenerateStub<IUserService>();
			userServiceStub.Stub(x => x.GetCurrentUser()).Return(new User("system"));
			userServiceStub.Stub(x => x.GetCurrentUserName()).Return("system");

			var sessionProvider = new SessionProvider(commerceConfigProviderStub, userServiceStub);

			return sessionProvider;
		}
	}
}