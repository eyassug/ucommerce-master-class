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
		private const string CONNECTIONSTRING = "Data Source=.;Initial Catalog=utraining;Integrated Security=true;";

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
		public void FindAllProductsForHomepage()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var products = session.Query<Product>()
					.Where(x => 
						x.ProductProperties.Any(
						y => y.ProductDefinitionField.Name == "ShowOnHomepage" 
							&& y.Value == "True"));
			}		
		}

		[Test]
		public void AdhocJoin()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = from orderline in session.Query<OrderLine>()
					join product in session.Query<Product>() on
						new {orderline.Sku, orderline.VariantSku} 
						equals new { product.Sku, product.VariantSku}
				select new {orderline, product};
			}
		}

		[Test]
		public void NPlus1()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var order = session.Query<PurchaseOrder>()
					.Fetch(x => x.BillingAddress)
					.FetchMany(x => x.OrderLines)
						.ThenFetch(x => x.Shipment)
					.First();
				var address = order.BillingAddress;
				var orderline = order.OrderLines;
			}
		}

		[Test]
		public void Hql()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.CreateQuery("from PurchaseOrder p")
					.Future<PurchaseOrder>();

				session.CreateQuery(@"from PurchaseOrder p
									join fetch p.BillingAddress")
					.Future<PurchaseOrder>();

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