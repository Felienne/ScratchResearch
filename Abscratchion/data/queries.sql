
----create tables, flatten blocks
----without variables
--Select distinct ST2.projectID, ST2.spriteType, ST2.spriteName, ST2.codeBlockRank, count(*) as lines,
--    substring(
--        (
--            Select ','+ST1.command  AS [text()]
--            From dbo.code ST1
--            Where ST1.projectID = ST2.projectID and ST1.codeBlockRank = ST2.codeBlockRank
--            ORDER BY ST1.codeBlockRank, St1.line
--            For XML PATH ('')
--        ), 2, 1000) [code]
--INTO clonesWithoutVariable
--From dbo.code ST2
--group by ST2.projectID, ST2.spriteType, ST2.spriteName, ST2.codeBlockRank
--order by codeBlockRank
----with variables
--Select distinct ST2.projectID, ST2.spriteType, ST2.spriteName, ST2.codeBlockRank, count(*) as lines,
--    substring(
--        (
--            Select ','+ST1.command+' '+ST1.param1+' '+ST1.param2+' '+ST1.param3+' '+ST1.param4+' '+ST1.param5+' '+ST1.param6  AS [text()]
--            From dbo.code ST1
--            Where ST1.projectID = ST2.projectID and ST1.codeBlockRank = ST2.codeBlockRank
--            ORDER BY ST1.codeBlockRank, St1.line
--            For XML PATH ('')
--        ), 2, 1000) [code]
--INTO clonesWithVariables
--From dbo.code ST2
--group by ST2.projectID, ST2.spriteType, ST2.spriteName, ST2.codeBlockRank
--order by codeBlockRank
----without the first event
--Select distinct ST2.projectID, ST2.spriteType, ST2.spriteName, ST2.codeBlockRank, count(*) as lines,
--    substring(
--        (
--            Select ','+ST1.command  AS [text()]
--            From dbo.code ST1
--            Where ST1.projectID = ST2.projectID and ST1.codeBlockRank = ST2.codeBlockRank
--			and line > 0
--            ORDER BY ST1.codeBlockRank, St1.line
--            For XML PATH ('')
--        ), 2, 1000) [code]
--INTO clonesWithoutEvent
--From dbo.code ST2
--group by ST2.projectID, ST2.spriteType, ST2.spriteName, ST2.codeBlockRank
--order by codeBlockRank
----normalized
--Select ST2.scriptID, count(*) as lines,
--    substring(
--        (
--            Select ','+ST1.command  AS [text()]
--            From dbo.code ST1
--            Where ST1.scriptID = ST2.scriptid
--			and line > 0
--            ORDER BY St1.line
--            For XML PATH ('')
--        ), 2, 3000) [code]
--INTO clonesWithoutEvent2
--From dbo.code ST2
--group by ST2.scriptid
--+ ALTER TABLE scriptsFlattened ADD CONSTRAINT scriptsFlattened_Fkey FOREIGN KEY(scriptid) REFERENCES scripts(scriptid) 
--+delete from scriptsFlattened where lines < 4
--+ delete from cloneswithoutevent2 where exists (select * from scripts s where cloneswithoutevent2.scriptid = s.scriptid and s.isremix = 1)
--  --select without variables, whole blocks, accross sprites
--  select a.lines, count(*)
--  from
--  (select projectid, spriteType, lines, code, count(distinct spriteName) as differentSprites, count(*) as clonesNo
--  FROM [Kragle].[dbo].[clonesWithoutVariable]
--  group by projectid, spriteType, lines, code
--  having count(*) >1) a
--  group by a.lines
--  --without variables, whole blocks, same sprite
--  select a.lines, count(*)
--  from
--  (select projectid, spriteType, spriteName, lines, code, count(*) as clonesNo
--  FROM [Kragle].[dbo].[clonesWithoutVariable]
--  where spriteType != 'procDef'
--  group by projectid, spriteType, spriteName, lines, code
--  having count(*) >1) a
--  group by a.lines
----for all three
--  delete from [Kragle].[dbo].[clonesWithVariables]
--  where lines < 5
-- --without variables, same sprites
--  select a.projectid, count(*)
--  from
--  (select projectid, spriteType, spriteName, lines, code, count(*) as clonesNo
--  FROM [Kragle].[dbo].[clonesWithoutVariable]
--  where spriteType != 'procDef'
--  group by projectid, spriteType, spriteName, lines, code
--  having count(*) >1) a
--  group by a.projectid
----accrosss spites
--  select a.projectid, count(*)
--  from
--  (select projectid, spriteType, lines, code, count(*) as clonesNo
--  FROM [Kragle].[dbo].clonesWithVariables
--  group by projectid, spriteType, lines, code
--  having count(*) >1) a
--  group by a.projectid
----cloned procedures
--  select a.projectid, count(*)
--  from
--  (select projectid, spriteType, lines, code, count(*) as clonesNo
--  FROM [Kragle].[dbo].[clonesWithoutVariable]
--  where spriteType = 'procDef'
--  group by projectid, spriteType, lines, code
--  having count(*) >1) a
--  group by a.projectid
----clonescopies
--select projectid, spriteType, lines, count(*) as clonesNo
--  FROM [Kragle].[dbo].clonesWithVariables
--  group by projectid, spriteType, lines, code
--  having count(*) >1
--  select projectid, spriteType, lines, count(*) as clonesNo
--  FROM [Kragle].[dbo].[clonesWithoutVariable]
--  where spriteType != 'procDef'
--  group by projectid, spriteType, spriteName, lines, code
--  having count(*) >1
-----functionality blocks cloned
--(
--  select projectid, minCodeBlock
--  from
--  (select projectid, spriteType, lines, code, min(codeblockRank) as minCodeBlock, count(*) as clonesNo
--  FROM [Kragle].[dbo].[clonesWithoutVariable]
--  group by projectid, spriteType, lines, code
--  having count(*) >1) as a
--  )
--  except
--  (
--  select projectid, minCodeBlock
--  from
--  (select projectid, spriteType, lines, code, min(codeblockrank) as minCodeBlock, count(*) as clonesNo
--  FROM [Kragle].[dbo].[clonesWithoutEvent]
--  group by projectid, spriteType, lines, code
--  having count(*) >1) as a
--  )
-----accross projects
--  select lines, code, count(*) as clonesNo, count(distinct projectid) as distinctProjects
--  FROM [Kragle].[dbo].clonesWithoutVariable
--  group by lines, code
--  having count(*) >100
--  order by distinctProjects desc

--  select a.lines, a.code, count(*) as clonesNo, count(distinct a.projectid) as distinctProjects, count(distinct a.spriteName) as distinctSprites
--  ,       substring(
--        (
--            Select top 50 ',' + b.spriteName + '(' + CAST(max(b.projectid) AS nvarchar(15)) + ',' + CAST(min(b.projectid) AS nvarchar(15)) + ')' AS [text()]
--			FROM [Kragle].[dbo].[clonesWithoutEvent] b
--            Where a.code = b.code
--			group by b.spriteName
--            For XML PATH ('')
--        ), 2, 1000) [projects]
--  FROM [Kragle].[dbo].[clonesWithoutEvent] a
--  group by a.lines, a.code
--  having count(*) > 1 and count(distinct a.projectid) > 1 and count(distinct a.spriteName) > 1

--    select a.lines, a.code,
--	count(*) as clonesNo,
--	count(distinct a.projectid) as distinctProjects,
--	count(distinct a.spriteName) as distinctSprites,
--	min(projectid) as projectid1, max(a.projectid) as projectid2
--  FROM [Kragle].[dbo].[clonesWithoutEvent] a
--  where not exists(select * from remixes r where a.projectid = r.remixid)
--  group by a.lines, a.code
--  having count(*) > 5 and count(distinct a.projectid) > 5 and count(distinct a.spriteName) > 5


----CREATE code fragmemtns
----of length:10
--DECLARE @startBlockIndex INT = 0;

--WHILE @startBlockIndex < 4330
--BEGIN
--		insert into codeFragments
--		   Select distinct ST2.projectID, ST2.spriteType, ST2.spriteName, ST2.codeBlockRank, 10 as lines,
--			substring(
--				(
--					Select top 10 ','+ST1.command  AS [text()]
--					From dbo.code ST1
--					Where ST1.projectID = ST2.projectID and ST1.codeBlockRank = ST2.codeBlockRank
--					and line >= @startBlockIndex
--					ORDER BY ST1.codeBlockRank, St1.line
--					For XML PATH ('')
--				), 2, 1000) [code]
--		From dbo.code ST2
--		--where projectID = 98670603
--		group by ST2.projectID, ST2.spriteType, ST2.spriteName, ST2.codeBlockRank
--		having count(*) >= 10 + @startBlockIndex
--		order by codeBlockRank
--		;

--   SET @startBlockIndex = @startBlockIndex + 1;
--END;

--PRINT 'Done';
--GO


----find same pieces of code
--DECLARE @startBlockIndex INT = 0;

--WHILE @startBlockIndex < 2
--BEGIN
--print @startBlockIndex;
--		RAISERROR(@startBlockIndex, 0, 1) WITH NOWAIT;
--		insert into codePieces
--		   Select
--			isnull(substring(
--				(
--					Select top 4 ','+ST1.command  AS [text()]
--					From dbo.code ST1
--					Where ST1.scriptID = ST2.ScriptID
--					and line >= @startBlockIndex
--					ORDER BY St1.line
--					For XML PATH ('')
--				), 2, 1000),''), 4
--		From dbo.code ST2 inner join scripts s on ST2.scriptid = s.scriptid
--		where s.totalLines >=4 + @startBlockIndex
--		and s.isremix = 0
--		--and projectID = 98670603
--		group by ST2.scriptID
--		having count(*) >= 4 + @startBlockIndex
--		;
		 
--   SET @startBlockIndex = @startBlockIndex + 1;
--END;

--PRINT 'Done';
--GO

--SET @startBlockIndex = 0;

--update codepieces set codefragment = replace(codefragment,'%','[%]')

--  select c.codeFragment, count(*), max(scriptid), min(scriptid)
--  from codepieces c, scriptsflattened s
--  where c.lines = 4
--  and s.code like '%' + c.codeFragment + '%'
--  group by c.codeFragment


  --final
  DECLARE @startBlockIndex INT = 0;

WHILE @startBlockIndex < 100
BEGIN
print @startBlockIndex;
		RAISERROR(@startBlockIndex, 0, 1) WITH NOWAIT;
		insert into test.dbo.codePieces
		   Select
			isnull(substring(
				(
					Select top 9 ','+ST1.command  AS [text()]
					From dbo.code ST1
					Where ST1.scriptID = ST2.ScriptID
					and line >= @startBlockIndex
					ORDER BY St1.line
					For XML PATH ('')
				), 2, 1000),''), 9, ST2.ScriptID
		From dbo.code ST2 inner join scripts s on ST2.scriptid = s.scriptid
		where s.totalLines >=9 + @startBlockIndex
		and s.isremix = 0
		--and projectID = 98670603
		group by ST2.scriptID
		having count(*) >= 9 + @startBlockIndex
		;
		 
   SET @startBlockIndex = @startBlockIndex + 1;
END;

PRINT 'Done';
GO

SET @startBlockIndex = 0;


----delete from test.dbo.codePieces
--SELECT  lines, [codeFragment], count(*) as total, min(scriptid) as script1, max(scriptid) as script2
--into test.dbo.aggregates
--  FROM [test].[dbo].[codepieces]
--  group by lines, codeFragment
--  having count(*) > 50

SELECT a.[lines]
      ,a.[codeFragment]
      ,a.[total]
      ,(select CONCAT(b.[projectID],'-',b.[spriteName]) from Kragle.dbo.scripts b where b.scriptID = a.script1)
      ,(select concat(b.[projectID],'-',b.[spriteName]) from Kragle.dbo.scripts b where b.scriptID = a.script2)
  FROM [test].[dbo].[aggregates] a
  order by a.total desc


  SELECT  a.lines, a.[codeFragment], count(*) as total, count(distinct b.scriptid) as disctinctScripts, count(distinct b.projectID) as distinctProjects, min(a.scriptid) as script1, max(a.scriptid) as script2
into test.dbo.aggregates3
  FROM [test].[dbo].[codepieces] a inner join Kragle.dbo.scripts b on a.scriptid = b.scriptID
  group by lines, codeFragment
  having count(*) > 50