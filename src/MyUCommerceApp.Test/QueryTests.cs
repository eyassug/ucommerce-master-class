using System.Linq;
using NHibernate.Hql.Ast.ANTLR;
using NUnit.Framework;
using Rhino.Mocks;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;
using UCommerce.Infrastructure.Configuration;
using NHibernate.Linq;
using UCommerce.Security;

namespace MyUCommerceApp.Test
{

	[TestFixture]
	public class QueryTests
	{
		private const string CONNECTIONSTRING = @"server=.\SQLExpress;database=MasterClass;user id=sa;password=SQLExpress2012";


		[Test]
		public void LinqQuery()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.Query<Product>()
					.Where(x => x.ProductProperties
					.Any(y => y.ProductDefinitionField.Name == "ShowOnHomePage" && y.Value == "True"))
					.ToList();
			}
		}

		[Test]
		public void PreFetch()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var orders = session.Query<PurchaseOrder>()
					.Fetch(x => x.Customer)
					.Fetch(x => x.BillingAddress)
					.FetchMany(x => x.OrderLines)
				.ToList();
			}
		}

		[Test]
		public void OrderLineProductJoin()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query =
					from orderLine in session.Query<OrderLine>()
					join product in session.Query<Product>()
						on new { orderLine.Sku, orderLine.VariantSku } equals
						new { product.Sku, product.VariantSku }
					select new { orderLine, product };

				var result = query.ToList();
			}
		}

		[Test]
		public void HqlTest()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.CreateQuery
					(@"
						select p from Product p
						left join fetch p.Variants
					").Future<Product>();

				session.CreateQuery(
				@"
						select p from Product p
						left join fetch p.ProductDefinition
				").Future<Product>();

				var result = query.ToList();
			}
		}

		[Test]
		public void Test()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var order = session.Query<PurchaseOrder>().First();
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