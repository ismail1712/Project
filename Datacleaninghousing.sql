select *
from portofolioproject..housing

 -- change date format

select SaleDate,cast(SaleDate as date)
from  portofolioproject.dbo.housing;

alter table portofolioproject.dbo.housing
add SaleDateConverted date;

update portofolioproject.dbo.housing
set SaleDateConverted = cast(SaleDate as date);

select SaleDateConverted
from portofolioproject..housing


--populate property address data

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from portofolioproject..housing a
join portofolioproject..housing b
on a.ParcelID=b.ParcelID
where a.[UniqueID ] <>  b.[UniqueID ]
and a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from portofolioproject..housing a
join portofolioproject..housing b
on a.ParcelID=b.ParcelID
where a.[UniqueID ] <>  b.[UniqueID ]

select *
from portofolioproject..housing
where PropertyAddress is null



--breaking address into individual columns

select PropertyAddress
from portofolioproject..housing

select 
substring(PropertyAddress,1,charindex(',',PropertyAddress,1)-1) as PropertySplitAddress,
substring(PropertyAddress,charindex(',',PropertyAddress,1)+1,len(PropertyAddress)) as PropertyCityAddress
from portofolioproject..housing

alter table portofolioproject.dbo.housing
add PropertySplitAddress nvarchar(255);

update portofolioproject.dbo.housing
set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress,1)-1);

alter table portofolioproject.dbo.housing
add PropertyCityAddress varchar(255);

update portofolioproject.dbo.housing
set PropertyCityAddress = substring(PropertyAddress,charindex(',',PropertyAddress,1)+1,len(PropertyAddress));


select OwnerAddress
from portofolioproject..housing



select 
substring(OwnerAddress,1,charindex('-',OwnerAddress,1)-1) as OwnerSplitAddress,
substring(OwnerAddress,charindex('-',OwnerAddress,1)+1,len(OwnerAddress)) as OwnerCityAddress,
substring(OwnerAddress,len(OwnerAddress)-2,len(OwnerAddress)) as OwnerStateAddress
from portofolioproject..housing

alter table portofolioproject.dbo.housing
add OwnerSplitAddress nvarchar(255);

update portofolioproject.dbo.housing
set OwnerSplitAddress = substring(OwnerAddress,1,charindex('-',OwnerAddress,1)-1)

alter table portofolioproject.dbo.housing
add OwnerCityAddress varchar(255);

update portofolioproject.dbo.housing
set OwnerCityAddress = substring(OwnerAddress,charindex('-',OwnerAddress,1)+1,len(OwnerAddress)) 


alter table portofolioproject.dbo.housing
add OwnerStateAddress varchar(255);

update portofolioproject.dbo.housing
set OwnerStateAddress = substring(OwnerAddress,len(OwnerAddress)-2,len(OwnerAddress)) 

select *
from portofolioproject..housing


--change y and n to yes and no in 'sold as vacant'

select distinct(SoldAsVacant)
from portofolioproject..housing

update portofolioproject.dbo.housing
set SoldAsVacant = 'not'
where SoldAsVacant='N'

--or

select distinct(SoldAsVacant)
,case when SoldAsVacant='not' then 'No'
when SoldAsVacant='Y' then 'Yes'
else SoldAsVacant
end
from portofolioproject..housing

update portofolioproject..housing
set SoldAsVacant = case when SoldAsVacant='not' then 'No'
when SoldAsVacant='Y' then 'Yes'
else SoldAsVacant
end


--remove duplicates

with rownumcte as (
select *,
row_number() over (
partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
order by UniqueID) row_num
from portofolioproject..housing
)
delete
from rownumcte
where row_num>1


--delete unused columns

select *
from portofolioproject..housing

alter table portofolioproject..housing
drop column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict

---
select a.OwnerName,b.OwnerName,a.ParcelID,b.ParcelID,isnull(a.OwnerName,b.OwnerName)
from portofolioproject..housing a
join portofolioproject..housing b
on a.ParcelID=b.ParcelID
where a.[UniqueID ] <>  b.[UniqueID ]
and a.OwnerName is null


delete
from portofolioproject..housing
where OwnerName is null and Acreage is null and LandValue is null

select *
from portofolioproject..housing
where YearBuilt is null


select a.YearBuilt,b.YearBuilt,a.OwnerSplitAddress,b.OwnerSplitAddress,isnull(a.YearBuilt,b.YearBuilt)
from portofolioproject..housing a
join portofolioproject..housing b
on a.OwnerSplitAddress=b.OwnerSplitAddress
where a.[UniqueID ] <>  b.[UniqueID ]
order by a.YearBuilt,b.YearBuilt

update a
set YearBuilt=isnull(a.YearBuilt,b.YearBuilt)
from portofolioproject..housing a
join portofolioproject..housing b
on a.OwnerSplitAddress=b.OwnerSplitAddress
where a.[UniqueID ] <>  b.[UniqueID ]
