# POCer på bruk av nasjonal infrastruktur som identitetsløsning

Dette repoet POCer noen alternative måter å bruke Maskinporten kan brukes som ekstern IDP for skyleverandører [eksemplifisert med GCP](gcp/README.md) og [Azure](azure/README.md)

## Skyporten – DigDir-basert tilgangsstyring av dataressurser i sky
![image](https://github.com/entur/sd-nasjonal-infrastruktur-poc/assets/264435/5a7587de-c4ac-4df9-9451-78da3cd40263)

Skyporten er i ferd med å settes i produksjon av DigDir. Implementasjonseksempler finnes her for:

* [GCP](gcp/cli)
* [Azure](azure)
* [AWS](aws/cli)

Eksempel på bruk av Skyporten i GCP:

![image](https://github.com/entur/sd-nasjonal-infrastruktur-poc/assets/264435/32425c82-e18c-4d97-903f-e93445e64aa6)

Autoriseringsflyt:

![image](https://github.com/entur/sd-nasjonal-infrastruktur-poc/assets/264435/eacbfd9b-f7d6-4d72-ae21-60786520a0af)



## Oppsett

Prosjektet krever at man har et ekte Maskinporten-token mot deres testmiljø. For testformål ble dette opprettet gjennom helperen her https://github.com/entur/exploratory-maskinporten-token. 

Ta kontakt med kontakt@samferdselsdata.no om du vil ha hjelp til å komme igang 

## Historie

Dette prosjektet begynte med demokode vist frem første gang på halvdagssamling 13.3.23 for teknisk fora i tverrsektorielt datasamarbeid.

Målet var å se eksempler på hvordan dele data ut av egen organisasjon med støtte i nasjonale løsninger for identitet for å slippe å håndtere identitet og onboarding i egen organisasjon.


## Tidligere utforskede alternativer

### DEPRECATED: Maskinporten foran et felles driftet hemmelighetslager

Maskinportentokens kan utveksles i leverandør/organisasjonsspesifikke hemmeligheter. Eksempelet bruker Maskinportenscopes foran [Hashicorp Vault](vault/README.md), som gir mulighet til lese og skriverettigheter kun basert på scopet i Maskinporten.
