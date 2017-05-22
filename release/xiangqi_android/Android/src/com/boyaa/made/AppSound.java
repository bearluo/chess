package com.boyaa.made;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import android.content.Context;
import android.media.AudioManager;
import android.media.SoundPool;

/**
 * 
 * This class is used for controlling effect
 * 
 */

public class AppSound {
	private Context mContext;
	private SoundPool mSoundPool;
	private float mLeftVolume;
	private float mRightVolume;

	// sound id and stream id map
	private HashMap<Integer, Integer> mSoundIdStreamIdMap;
	// sound path and sound id map
	private HashMap<String, Integer> mPathSoundIDMap;
	private HashMap<Integer, Integer> mAutoplaySoundIDMap;

	private static final String TAG = "AppSound";
	private static final int MAX_SIMULTANEOUS_STREAMS_DEFAULT = 5;
	private static final float SOUND_RATE = 1.0f;
	private static final int SOUND_PRIORITY = 1;
	private static final int SOUND_QUALITY = 5;

	private final int INVALID_SOUND_ID = -1;
	private final int INVALID_STREAM_ID = -1;

	public AppSound() {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				initData();
			}
		});
	}
	
	void RunOnThread(final Runnable runnable){
		new Thread(new Runnable(){
			@Override
			public void run() {
				synchronized (AppSound.this) {
					runnable.run();
					AppSound.this.notifyAll();
				}
			}
		}).start();
	}

	public int preloadEffect2(String path) {
		int soundId = INVALID_SOUND_ID;

		// if the sound is preloaded, pass it
		if (this.mPathSoundIDMap.get(path) != null) {
			soundId = this.mPathSoundIDMap.get(path).intValue();
		} else {
			soundId = createSoundIdFromAsset(path);

			if (soundId != INVALID_SOUND_ID) {
				// the sound is loaded but has not been played
				this.mSoundIdStreamIdMap.put(soundId, INVALID_STREAM_ID);

				// record path and sound id map
				this.mPathSoundIDMap.put(path, soundId);
			}
		}

		return soundId;
	}
	
	public void preloadEffect(final String path) {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				preloadEffect2(path);
			}
		});
	}

	public void unloadEffect(final String path) {
		/*RunOnThread(new Runnable(){
			@Override
			public void run() {
				// TODO Auto-generated method stub
				// get sound id and remove from mPathSoundIDMap
				Integer soundId = AppSound.this.mPathSoundIDMap.remove(path);
			
				if (soundId != null) {
					// unload effect
					AppSound.this.mSoundPool.unload(soundId.intValue());
			
					// remove record from mSoundIdStreamIdMap
					AppSound.this.mSoundIdStreamIdMap.remove(soundId);
				}
			}
		});*/
	}

	public int playEffect(String path, boolean isLoop) {
		Integer soundId = this.mPathSoundIDMap.get(path);
		

		if (soundId != null) {
			// the sound is preloaded, stop it first

			this.mSoundPool.stop(soundId);
			
			int streamId = this.mSoundPool.play(soundId.intValue(), this.mLeftVolume, this.mRightVolume, SOUND_PRIORITY, isLoop ? -1 : 0, SOUND_RATE);

			// record sound id and stream id map
			this.mSoundIdStreamIdMap.put(soundId, streamId);
		} else {
			// the effect is not prepared
			soundId = preloadEffect2(path);
			if (soundId == INVALID_SOUND_ID) {
				// can not preload effect
				return INVALID_SOUND_ID;
			}
			this.mAutoplaySoundIDMap.put(soundId, isLoop?2:1);

			/*
			 * Someone reports that, it can not play effect for the first time.
			 * If you are lucky to meet it. There are two ways to resolve it. 1.
			 * Add some delay here. I don't know how long it is, so I don't add
			 * it here. 2. If you use 2.2(API level 8), you can call
			 * SoundPool.setOnLoadCompleteListener() to play the effect. Because
			 * the method is supported from 2.2, so I can't use it here.
			 */
			//playEffect(path, isLoop);
		}

		return soundId.intValue();
	}
	
	public void stopEffect2(final int soundId) {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				Integer streamId = mSoundIdStreamIdMap.get(soundId);
		
				if (streamId != null && streamId.intValue() != INVALID_STREAM_ID) {
					mSoundPool.stop(streamId.intValue());
					mPathSoundIDMap.remove(soundId);
					mAutoplaySoundIDMap.remove(soundId);
				}
			}
		});
	}

	public void stopEffect(final int soundId) {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				stopEffect2(soundId);
			}
		});
	}

	public void pauseEffect(final int soundId) {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				Integer streamId = mSoundIdStreamIdMap.get(soundId);
		
				if (streamId != null && streamId.intValue() != INVALID_STREAM_ID) {
					mSoundPool.pause(streamId.intValue());
					mPathSoundIDMap.remove(soundId);
				}
			}
		});
	}

	public void resumeEffect(final int soundId) {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				Integer streamId = mSoundIdStreamIdMap.get(soundId);
		
				if (streamId != null && streamId.intValue() != INVALID_STREAM_ID) {
					mSoundPool.resume(streamId.intValue());
					mPathSoundIDMap.remove(soundId);
				}
			}
		});
	}

	public void pauseAllEffects() {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				// autoResume is available since level 8
				pauseOrResumeAllEffects(true);
			}
		});
	}

	public void resumeAllEffects() {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				// autoPause() is available since level 8
				pauseOrResumeAllEffects(false);
			}
		});
	}

	@SuppressWarnings("unchecked")
	public void stopAllEffects() {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				Iterator<?> iter = mSoundIdStreamIdMap.entrySet().iterator();
				while (iter.hasNext()) {
					Map.Entry<Integer, Integer> entry = (Map.Entry<Integer, Integer>) iter.next();
					int soundId = entry.getKey();
					stopEffect2(soundId);
				}			
			}
		});
	}

	public float getEffectsVolume() {
		return (mLeftVolume + mRightVolume) / 2;
	}

	@SuppressWarnings("unchecked")
	public void setEffectsVolume(final float volume) {
		float vv = volume;
		// volume should be in [0, 1.0]
		if (vv < 0) {
			vv = 0;
		}
		if (vv > 1) {
			vv = 1;
		}
		mLeftVolume = mRightVolume = vv;
		
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				// change the volume of playing sounds
				Iterator<?> iter = mSoundIdStreamIdMap.entrySet().iterator();
				while (iter.hasNext()) {
					Map.Entry<Integer, Integer> entry = (Map.Entry<Integer, Integer>) iter.next();
					mSoundPool.setVolume(entry.getValue(), mLeftVolume, mRightVolume);
				}
			}
		});
	}

	public void end() {
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				mSoundPool.release();
				mPathSoundIDMap.clear();
				mSoundIdStreamIdMap.clear();
				mAutoplaySoundIDMap.clear();
				
				initData();
			}
		});
	}
	public void Release()
	{
		RunOnThread(new Runnable(){
			@Override
			public void run() {
				mSoundPool.release();
				mPathSoundIDMap.clear();
				mSoundIdStreamIdMap.clear();	
				mAutoplaySoundIDMap.clear();
			}
		});
	}

	public int createSoundIdFromAsset(String path) {
		int soundId = INVALID_SOUND_ID;

		try {
			soundId = mSoundPool.load(path, 0);
		} catch (Exception e) {
			soundId = INVALID_SOUND_ID;
		}

		return soundId;
	}
	
	public void soundLoadComplete(final int soundId)
	{
		if( !this.mAutoplaySoundIDMap.containsKey(soundId) )
		{
			return;
		}
		int value = this.mAutoplaySoundIDMap.get(soundId); 
		if( value > 0 )
		{
			int streamId = this.mSoundPool.play(soundId, this.mLeftVolume, this.mRightVolume, SOUND_PRIORITY, (value == 2) ? -1 : 0, SOUND_RATE);

			// record sound id and stream id map
			this.mSoundIdStreamIdMap.put(soundId, streamId);
			this.mAutoplaySoundIDMap.remove(soundId);
		}
	}

	private void initData() {
		this.mSoundIdStreamIdMap = new HashMap<Integer, Integer>();
		HashMap<Integer, Integer> autoplaymap = new HashMap<Integer, Integer>(); 
		this.mAutoplaySoundIDMap = autoplaymap;
		mSoundPool = new SoundPool(MAX_SIMULTANEOUS_STREAMS_DEFAULT, AudioManager.STREAM_MUSIC, SOUND_QUALITY);
		
		mSoundPool.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener(){
			@Override
			public void onLoadComplete(SoundPool soundPool, int sampleId,
					int status) {
				final int sid = sampleId;
				RunOnThread(new Runnable(){
					@Override
					public void run() {
						soundLoadComplete(sid);
					}
				});
			}
		});
		
		mPathSoundIDMap = new HashMap<String, Integer>();

		this.mLeftVolume = 0.5f;
		this.mRightVolume = 0.5f;
	}

	@SuppressWarnings("unchecked")
	private void pauseOrResumeAllEffects(boolean isPause) {
		Iterator<?> iter = this.mSoundIdStreamIdMap.entrySet().iterator();
		while (iter.hasNext()) {
			Map.Entry<Integer, Integer> entry = (Map.Entry<Integer, Integer>) iter.next();
			int soundId = entry.getKey();
			if (isPause) {
				this.pauseEffect(soundId);
			} else {
				this.resumeEffect(soundId);
			}
		}
	}
}
