# POC på bruk av nasjonal infrastruktur som identitetsløsning

Dette prosjektet inneholder demokode vist frem første gang på halvdagssamling 13.3.23 for teknisk fora i tverrsektorielt datasamarbeid.

Målet var å se eksempler på hvordan dele data ut av egen organisasjon med støtte i nasjonale løsninger for identitet for å slippe å håndtere identitet og onboarding i egen organisasjon.


## Oppsett

Prosjektet krever at man har et ekte Maskinporten-token mot deres testmiljø. For testformål ble dette opprettet gjennom helperen her https://github.com/entur/exploratory-maskinporten-token. 

Ta kontakt med post@samferdselsdata.no om du vil ha hjelp til å komme igang 

Dette repoet POC'er noen alternative måter å bruke Maskinporten kan brukes som ekstern IDP for skyleverandører [eksemplifisert med GCP](gcp/README.md) og [Azure](azure/README.md)

## Tidligere utforskede alternativer

### DEPRECATED: Maskinporten foran et felles driftet hemmelighetslager

Maskinportentokens kan utveksles i leverandør/organisasjonsspesifikke hemmeligheter. Eksempelet bruker Maskinportenscopes foran [Hashicorp Vault](vault/README.md), som gir mulighet til lese og skriverettigheter kun basert på scopet i Maskinporten.
